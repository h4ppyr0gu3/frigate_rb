# frozen_string_literal: true

require_relative "collection"

module FrigateRb
  # Any common utility functions
  module Utils
    def wrap_response(response, type = nil, client: FrigateRb.client)
      if type.present?
        records = response.map do |record|
          type.new(record, client: client)
        end
        Collection.new(records)
      else
        Collection.new(response)
      end
    end

    def parsed_response(response, type, client: FrigateRb.client)
      if response.success?
        handle_response(response, type, client: client)
      else
        FrigateRb::Types::Error.new(response.body, response.status)
      end
    end

    def handle_response(response, type, client: FrigateRb.client)
      if response.body.is_a?(Array)
        wrap_response(response.body, type, client: client)
      elsif response.body.is_a?(String)
        type.new(JSON.parse(response.body), client: client)
      else
        type.new(response.body, client: client)
      end
    end
  end
end
