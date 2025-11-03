# frozen_string_literal: true

require_relative "frigate_rb/version"
require_relative "frigate_rb/configuration"
require_relative "frigate_rb/types"
require_relative "frigate_rb/client"
require_relative "frigate_rb/camera"
require_relative "frigate_rb/endpoints"
require_relative "frigate_rb/event"
require_relative "frigate_rb/review"
require_relative "frigate_rb/utils"
require_relative "frigate_rb/info"
require_relative "frigate_rb/mqtt/listener"
require_relative "frigate_rb/faces"

require "active_support"
require "active_support/all"

# FrigateRb is a library to interact with https://frigate.video, it is configurable
# through the FrigateRb::Configuration class
# it is designed to be able to be extensible
module FrigateRb
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
