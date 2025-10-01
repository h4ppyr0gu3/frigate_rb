# frozen_string_literal: true

require_relative "collection"

module FrigateRb
  # Any common utility functions
  module Utils
    def wrap_response(response)
      Collection.new(response)
    end
  end
end
