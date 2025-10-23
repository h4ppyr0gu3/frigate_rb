# frozen_string_literal: true

require "faraday"
require "faraday-cookie_jar"
require "faraday/net_http_persistent"
require "singleton"
require "pry"

module FrigateRb
  # client to interact with the Frigate API
  # here we initialize a cookie jar and a faraday connection
  # which we use with every request, if there is no session cookie we rerun the auth
  class Client
    include Singleton
    InvalidCredentials = Class.new(StandardError)
    FRIGATE_SESSION_COOKIE_NAME = "frigate_token"

    attr_accessor :session_cookie, :session_expires_at
    attr_reader :connection, :cookie_jar

    def initialize(session_cookie: nil, session_expires_at: nil, streaming: false)
      @session_cookie = session_cookie
      @session_expires_at = session_expires_at

      @cookie_jar = HTTP::CookieJar.new

      @connection = create_connection(@cookie_jar)
    end

    def create_streaming_connection(jar)
      Faraday.new(url: FrigateRb.configuration.frigate_https_url, ssl: { verify: false }) do |builder|
        builder.use :cookie_jar, jar: jar

        builder.adapter :net_http_persistent, stream_response: true

        puts "--- STREAMING CONNECTION STACK ---"
        puts builder.adapter.inspect
        puts "------------------------------------"
      end
    end

    def create_connection(jar)
      @connection = Faraday.new(url: FrigateRb.configuration.frigate_https_url, ssl: { verify: false }) do |builder|
        builder.use :cookie_jar, jar: jar
        builder.request :json

        builder.response :json,
                         content_type: /\bjson$/,
                         parser_options: {
                           symbolize_names: true
                         }
        # builder.response :logger,
        #   nil,
        #   {
        #     headers: true,
        #     bodies: true,
        #     log_level: :info
        #   }
        builder.adapter Faraday.default_adapter
      end
    end

    def authenticate # rubocop:disable Metrics/MethodLength
      connection = self.connection

      payload = {
        "user" => FrigateRb.configuration.frigate_username,
        "password" => FrigateRb.configuration.frigate_password
      }

      response = connection.post(
        FrigateRb::Endpoints.login,
        payload.to_json
      )

      raise InvalidCredentials unless response.success?

      extract_session_details

      connection
    end

    def get(path, params = {}, headers = {})
      authenticate if @session_cookie.nil? || @session_expires_at < Time.now

      @connection.get(path, params, headers)
    end

    def post(path, body = {}, headers = {})
      authenticate if @session_cookie.nil? || @session_expires_at < Time.now

      @connection.post(path, body, headers)
    end

    def stream(path, _params = {}, range_header: nil)
      authenticate if @session_cookie.nil? || @session_expires_at < Time.now

      conn = create_streaming_connection(@cookie_jar)

      faraday_response = conn.get(path) do |req|
        req.headers["Range"] = range_header if range_header
      end

      proxy_headers = {
        "status" => faraday_response.status,
        "Content-Type" => faraday_response.headers["Content-Type"],
        "Content-Length" => faraday_response.headers["Content-Length"],
        "Accept-Ranges" => faraday_response.headers["Accept-Ranges"],
        "Content-Range" => faraday_response.headers["Content-Range"]
      }.compact

      body_enumerator =
        if faraday_response.body.respond_to?(:read_body)
          # Streaming body (IO-like)
          Enumerator.new do |yielder|
            faraday_response.body.read_body do |chunk|
              yielder << chunk
            end
          rescue Errno::EPIPE, IOError
            # Client disconnected
            nil
          end
        else
          # Non-streaming response (String body)
          Enumerator.new do |yielder|
            yielder << faraday_response.body.to_s
          end
        end

      yield proxy_headers, body_enumerator
    rescue Faraday::Error => e
      Rails.logger.error "VideoProxyStreamer Error: #{e.message}"

      headers = { "status" => 502, "Content-Type" => "text/plain" }
      body = Enumerator.new { |y| y << "Upstream proxy request failed." }

      yield headers, body
    end

    def extract_session_details
      jar = @cookie_jar

      session_cookie_info = jar.cookies.find do |cookie|
        cookie.name == FRIGATE_SESSION_COOKIE_NAME
      end

      raise InvalidCredentials unless session_cookie_info

      @session_cookie = session_cookie_info.value
      @session_expires_at = session_cookie_info.expires

      self
    end
  end
end
