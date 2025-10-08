# frozen_string_literal: true

require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Review from the API
  class Review
    extend FrigateRb::Utils

    def self.all
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.reviews)
      parsed_response(response, FrigateRb::Types::Review)
    end

    def self.find(id)
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.review(id))
      parsed_response(response, FrigateRb::Types::Review)
    end

    def self.where(params = {})
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.reviews, params)
      parsed_response(response, FrigateRb::Types::Review)
    end

    def self.from_event(event_id)
      response = FrigateRb::Client.instance.get(
        FrigateRb::Endpoints.review_from_event(event_id)
      )

      parsed_response(response, FrigateRb::Types::Review)
    end

    def self.multiple_reviewed(ids)
      response = FrigateRb::Client.instance.post(
        FrigateRb::Endpoints.multiple_reviewed, { ids: ids }
      )

      parsed_response(response, FrigateRb::Types::Success)
    end
  end
end
