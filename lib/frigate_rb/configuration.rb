# frozen_string_literal: true

module FrigateRb
  # This class holds the configuration for the FrigateRb gem
  # this can be configured by calling
  # FrigateRb.configure do |config|
  #  config.frigate_https_url = "https://localhost:8971"
  # end
  class Configuration
    attr_accessor :frigate_https_url, :frigate_mqtt_url, :frigate_username,
                  :frigate_password, :frigate_mqtt_username, :frigate_mqtt_password,
                  :open_timeout, :request_timeout, :stream_timeout

    # class FrigateRbError < StandardError; end

    def initialize
      @frigate_https_url = "https://localhost:8971"
      @frigate_mqtt_url = "mqtt://localhost:1883"
      @frigate_mqtt_username = "mqttuser"
      @frigate_mqtt_password = "mysecretpassword"
      @frigate_username = "admin"
      @frigate_password = ""
      # Hung Frigate calls otherwise pin workers indefinitely.
      @open_timeout = 5
      @request_timeout = 15
      # Streaming builds clip.mp4 on demand from recording segments.
      @stream_timeout = 120
    end
  end
end
