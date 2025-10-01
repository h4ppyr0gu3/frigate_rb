# frozen_string_literal: true

require "faraday"
require "faraday-cookie_jar"
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

    def initialize(session_cookie: nil, session_expires_at: nil)
      @session_cookie = session_cookie
      @session_expires_at = session_expires_at

      @cookie_jar = HTTP::CookieJar.new

      @connection = create_connection(@cookie_jar)
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
