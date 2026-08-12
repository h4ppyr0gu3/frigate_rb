# frozen_string_literal: true

require "faraday"
require "faraday-cookie_jar"
require "faraday/net_http_persistent"
require "faraday/multipart"
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
    # Renew slightly before the cookie's Expires so in-flight requests don't race expiry.
    SESSION_RENEWAL_SKEW = 60
    # Used when Frigate omits Expires on frigate_token.
    DEFAULT_SESSION_TTL = 3600

    attr_accessor :session_cookie, :session_expires_at
    attr_reader :connection, :cookie_jar

    def initialize(session_cookie: nil, session_expires_at: nil, streaming: false)
      @session_cookie = session_cookie
      @session_expires_at = session_expires_at

      @cookie_jar = HTTP::CookieJar.new

      @connection = create_connection(@cookie_jar)
    end

    def create_streaming_connection(jar)
      Faraday.new(**connection_options(streaming: true)) do |builder|
        builder.use :cookie_jar, jar: jar

        builder.adapter :net_http_persistent, stream_response: true
      end
    end

    def create_multipart_connection(jar)
      Faraday.new(**connection_options) do |builder|
        builder.use :cookie_jar, jar: jar

        builder.request :multipart
      end
    end

    def create_connection(jar)
      @connection = Faraday.new(**connection_options) do |builder|
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

    def post_file(path, file, type = "image/jpeg")
      with_auth_retry do
        conn = create_multipart_connection(@cookie_jar)
        payload = {}

        payload[:file] = Faraday::Multipart::FilePart.new(file, type)

        conn.post(path, payload)
      end
    end

    def authenticate # rubocop:disable Metrics/MethodLength
      clear_session!

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
      with_auth_retry { @connection.get(path, params, headers) }
    end

    def post(path, body = {}, headers = {})
      with_auth_retry { @connection.post(path, body, headers) }
    end

    def stream(path, _params = {}, range_header: nil)
      ensure_authenticated!

      faraday_response = nil
      2.times do |attempt|
        conn = create_streaming_connection(@cookie_jar)

        faraday_response = conn.get(path) do |req|
          req.headers["Range"] = range_header if range_header
        end

        break if faraday_response.status != 401 || attempt.positive?

        authenticate
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

    def session_valid?
      !@session_cookie.nil? &&
        !@session_expires_at.nil? &&
        @session_expires_at > Time.now + SESSION_RENEWAL_SKEW
    end

    def ensure_authenticated!
      authenticate unless session_valid?
    end

    def extract_session_details
      jar = @cookie_jar

      session_cookie_info = jar.cookies.find do |cookie|
        cookie.name == FRIGATE_SESSION_COOKIE_NAME
      end

      raise InvalidCredentials unless session_cookie_info

      @session_cookie = session_cookie_info.value
      @session_expires_at = session_cookie_info.expires || (Time.now + DEFAULT_SESSION_TTL)

      self
    end

    private

    def connection_options(streaming: false)
      config = FrigateRb.configuration
      read_timeout = streaming ? config.stream_timeout : config.request_timeout

      {
        url: config.frigate_https_url,
        ssl: { verify: false },
        request: {
          open_timeout: config.open_timeout,
          timeout: read_timeout,
          write_timeout: read_timeout
        }
      }
    end

    def clear_session!
      @session_cookie = nil
      @session_expires_at = nil
      @cookie_jar.clear
    end

    def unauthorized?(response)
      response.status == 401
    end

    def with_auth_retry
      ensure_authenticated!
      response = yield
      return response unless unauthorized?(response)

      authenticate
      yield
    end
  end
end
