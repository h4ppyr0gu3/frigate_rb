# frozen_string_literal: true

require_relative "types/review"
require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Review from the API
  class Review
    extend FrigateRb::Utils

    def self.all
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.reviews)

      reviews = response.body.map do |review|
        FrigateRb::Types::Review.new(review)
      end

      wrap_response(reviews)
    end

    def self.find(id)
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.review(id))

      FrigateRb::Types::Review.new(response.body)
    end

    def self.where(params = {})
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.reviews, params)

      reviews = response.body.map do |review|
        FrigateRb::Types::Review.new(review)
      end

      wrap_response(reviews)
    end
  end
end
