# frozen_string_literal: true

require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Review from the API
  class Review
    extend FrigateRb::Utils

    def self.all(client: FrigateRb.client)
      response = client.get(FrigateRb::Endpoints.reviews)
      parsed_response(response, FrigateRb::Types::Review, client: client)
    end

    def self.find(id, client: FrigateRb.client)
      response = client.get(FrigateRb::Endpoints.review(id))
      parsed_response(response, FrigateRb::Types::Review, client: client)
    end

    def self.where(params = nil, client: FrigateRb.client, **kwargs)
      params = (params || {}).merge(kwargs)
      response = client.get(FrigateRb::Endpoints.reviews, params)
      parsed_response(response, FrigateRb::Types::Review, client: client)
    end

    def self.from_event(event_id, client: FrigateRb.client)
      response = client.get(
        FrigateRb::Endpoints.review_from_event(event_id)
      )

      parsed_response(response, FrigateRb::Types::Review, client: client)
    end

    def self.multiple_reviewed(ids, client: FrigateRb.client)
      response = client.post(
        FrigateRb::Endpoints.multiple_reviewed, { ids: ids }
      )

      parsed_response(response, FrigateRb::Types::Success)
    end
  end
end
