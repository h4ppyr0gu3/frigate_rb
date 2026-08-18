# frozen_string_literal: true

require_relative "types/event"
require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Events from the API
  class Event
    extend FrigateRb::Utils

    def self.all(client: FrigateRb.client)
      response = client.get(FrigateRb::Endpoints.events)
      parsed_response(response, FrigateRb::Types::Event, client: client)
    end

    def self.find(id, client: FrigateRb.client)
      response = client.get(FrigateRb::Endpoints.event(id))
      parsed_response(response, FrigateRb::Types::Event, client: client)
    end

    def self.find_by_ids(ids, client: FrigateRb.client)
      response = client.get(
        FrigateRb::Endpoints.event_ids,
        { ids: ids.join(",") }
      )
      parsed_response(response, FrigateRb::Types::Event, client: client)
    end

    def self.where(params = nil, client: FrigateRb.client, **kwargs)
      params = (params || {}).merge(kwargs)
      response = client.get(FrigateRb::Endpoints.events, params)
      parsed_response(response, FrigateRb::Types::Event, client: client)
    end
  end
end
