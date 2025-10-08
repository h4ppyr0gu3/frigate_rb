# frozen_string_literal: true

require_relative "collection"

module FrigateRb
  # Any common utility functions
  module Utils
    def wrap_response(response, type = nil)
      if type.present?
        records = response.map do |record|
          type.new(record)
        end
        Collection.new(records)
      else
        Collection.new(response)
      end
    end

    def parsed_response(response, type)
      if response.success?
        handle_response(response, type)
      else
        FrigateRb::Types::Error.new(response.body, response.status)
      end
    end

    def handle_response(response, type)
      if response.body.is_a?(Array)
        wrap_response(response.body, type)
      else
        type.new(response.body)
      end
    end
  end
end
