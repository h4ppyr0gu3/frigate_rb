# frozen_string_literal: true

require_relative "types/event"
require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Events from the API
  class Event
    extend FrigateRb::Utils

    def self.all
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.events)

      events = response.body.map do |event|
        FrigateRb::Types::Event.new(event)
      end

      wrap_response(events)
    end

    def self.find(id)
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.event(id))

      FrigateRb::Types::Event.new(response.body)
    end

    def self.where(params = {})
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.events, params)

      events = response.body.map do |event|
        FrigateRb::Types::Event.new(event)
      end

      wrap_response(events)
    end
  end
end
