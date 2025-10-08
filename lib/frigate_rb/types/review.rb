# frozen_string_literal: true

require_relative "type_utils"

module FrigateRb
  module Types
    class Review
      include TypeUtils
      attr_reader :id, :camera, :start_time, :end_time, :severity, :thumb_path, :data, :has_been_reviewed

      def initialize(type)
        @id = type[:id]
        @camera = type[:camera]
        @start_time = Time.at(type[:start_time])
        @end_time = Time.at(type[:end_time])
        @severity = type[:severity]
        @thumb_path = type[:thumb_path]
        @data = type[:data]
        @has_been_reviewed = type[:has_been_reviewed]
      end

      def events
        return nil unless data.present?

        ids = data[:detections]

        FrigateRb::Event.find_by_ids(ids)
      end
    end
  end
end
