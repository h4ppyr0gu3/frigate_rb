# frozen_string_literal: true

require_relative "types/event"
require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Events from the API
  class Event
    extend FrigateRb::Utils

    def self.all
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.events)
      parsed_response(response, FrigateRb::Types::Event)
    end

    def self.find(id)
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.event(id))
      parsed_response(response, FrigateRb::Types::Event)
    end

    def self.find_by_ids(ids)
      response = FrigateRb::Client.instance.get(
        FrigateRb::Endpoints.event_ids,
        { ids: ids.join(",") }
      )
      parsed_response(response, FrigateRb::Types::Event)
    end

    def self.where(params = {})
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.events, params)
      parsed_response(response, FrigateRb::Types::Event)
    end
  end
end
