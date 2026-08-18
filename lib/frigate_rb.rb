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
#
# == Multi-instance support (0.2.x)
#
# Multiple named Frigate nodes can be registered and used independently:
#
#   FrigateRb.configure(:frigate)  { |c| c.frigate_https_url = "https://nvr1:8971" }
#   FrigateRb.configure(:frigate2) { |c| c.frigate_https_url = "https://nvr2:8971" }
#
#   FrigateRb.client(:frigate)   # memoized Client + cookie jar
#   FrigateRb.client(:frigate2)  # separate memoized Client + cookie jar
#   FrigateRb.clients            # { frigate: Client, frigate2: Client, ... }
#
#   FrigateRb::Event.find(id, client: FrigateRb.client(:frigate2))
#   # Types::Event#mark_as_reviewed uses the client it was fetched with
#
# == Backward compatibility
#
# Calling +configure+ / +client+ / +configuration+ without a name defaults to
# +:default+.  +FrigateRb::Client.instance+ is kept as an alias for
# +FrigateRb.client(:default)+ for one release so existing callers keep working.
module FrigateRb
  class Error < StandardError; end

  DEFAULT_CLIENT_NAME = :default

  class << self
    # Yields the named configuration (default +:default+) for mutation.
    def configure(name = DEFAULT_CLIENT_NAME)
      yield(configuration(name))
    end

    # Returns the memoized Configuration for +name+ (default +:default+).
    def configuration(name = DEFAULT_CLIENT_NAME)
      configurations[name] ||= Configuration.new
    end

    # Returns a memoized Client for +name+ (default +:default+).
    # The client carries its own cookie jar and configuration.
    def client(name = DEFAULT_CLIENT_NAME)
      clients[name] ||= Client.new(configuration: configuration(name))
    end

    # Returns the hash of all memoized clients keyed by name.
    def clients
      @clients ||= {}
    end

    # Returns the hash of all configurations keyed by name.
    def configurations
      @configurations ||= {}
    end

    # Removes a named client and its configuration from the registry.
    # Useful when a Frigate instance row is destroyed.
    def unregister(name)
      clients.delete(name)
      configurations.delete(name)
    end

    # Rebuilds a named client (new cookie session).
    # Pass a block to update the configuration before the client is rebuilt:
    #
    #   FrigateRb.reload(:frigate) { |c| c.frigate_https_url = new_url }
    #
    # Without a block the existing configuration is preserved — only the
    # memoized client and its cookie jar are discarded.
    def reload(name = DEFAULT_CLIENT_NAME)
      clients.delete(name)
      yield(configuration(name)) if block_given?
      client(name)
    end

    # Clears all memoized clients and configurations.
    # Primarily useful in tests; callers that need a fresh client should
    # use +reload+ or +unregister+ instead.
    def reset!
      @clients&.clear
      @configurations&.clear
    end
  end
end
