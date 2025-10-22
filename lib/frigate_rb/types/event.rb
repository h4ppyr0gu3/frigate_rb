# frozen_string_literal: true

require_relative "type_utils"

module FrigateRb
  module Types
    # Type of Event data that comes from frigate
    class Event
      include TypeUtils

      attr_accessor :id, :camera, :label, :zones, :start_time, :end_time, :has_clip, :has_snapshot, :plus_id,
                    :retain_indefinitely, :sub_label, :top_score, :false_positive, :box, :data, :thumbnail,
                    :recognized_license_plate, :recognized_license_plate_score, :score

      def initialize(data) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        @id = data[:id]
        @camera = data[:camera]
        @label = data[:label]
        @zones = data[:zones]
        @start_time = try_parse_date(data, :start_time)
        @end_time = try_parse_date(data, :end_time)
        @has_clip = data[:has_clip]
        @has_snapshot = data[:has_snapshot]
        @plus_id = data[:plus_id]
        @retain_indefinitely = data[:retain_indefinitely]
        @sub_label = data[:sub_label]
        @top_score = data[:top_score]
        @score = data[:score]
        @false_positive = data[:false_positive]
        @box = data[:box]
        @data = data[:data]
        @thumbnail = data[:thumbnail]
        @recognized_license_plate = data[:recognized_license_plate]
        @recognized_license_plate_score = data[:recognized_license_plate_score]
      end

      def clip
        response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.event_clip(id))

        return unless response.success?

        mp4 = response.body
        File.open("frigate_clip.mp4", "wb") do |f|
          f.write(mp4)
        end
      end

      def mark_as_reviewed
        review = FrigateRb::Review.from_event(id)
        return unless review.is_a?(FrigateRb::Types::Review)

        review_id = review.id
        FrigateRb::Review.multiple_reviewed([review_id])
      end
    end
  end
end
