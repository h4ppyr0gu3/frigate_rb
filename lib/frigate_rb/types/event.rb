# frozen_string_literal: true

module FrigateRb
  module Types
    # Type of Event data that comes from frigate
    class Event
      attr_accessor :id, :camera, :label, :zones, :start_time, :end_time, :has_clip, :has_snapshot, :plus_id,
                    :retain_indefinitely, :sub_label, :top_score, :false_positive, :box, :data, :thumbnail

      def initialize(data) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        @id = data[:id]
        @camera = data[:camera]
        @label = data[:label]
        @zones = data[:zones]
        @start_time = Time.at(data[:start_time])
        # end time isn't present in the beginning
        @end_time = Time.at(data[:end_time]) if data[:end_time].present?
        @has_clip = data[:has_clip]
        @has_snapshot = data[:has_snapshot]
        @plus_id = data[:plus_id]
        @retain_indefinitely = data[:retain_indefinitely]
        @sub_label = data[:sub_label]
        @top_score = data[:top_score]
        @false_positive = data[:false_positive]
        @box = data[:box]
        @data = data[:data]
        @thumbnail = data[:thumbnail]
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
        FrigateRb::Review.multiple_reviewed([id])
      end
    end
  end
end
