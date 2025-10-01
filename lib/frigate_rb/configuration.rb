# frozen_string_literal: true

module FrigateRb
  # This class holds the configuration for the FrigateRb gem
  # this can be configured by calling
  # FrigateRb.configure do |config|
  #  config.frigate_https_url = "https://localhost:8971"
  # end
  class Configuration
    attr_accessor :frigate_https_url, :frigate_mqtt_url, :frigate_username,
                  :frigate_password

    # class FrigateRbError < StandardError; end

    def initialize
      @frigate_https_url = "https://localhost:8971"
      @frigate_mqtt_url = "mqtt://localhost:1883"
      @frigate_username = "admin"
      @frigate_password = ""
    end
  end
end
