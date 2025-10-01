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
        @start_time = data[:start_time]
        @end_time = data[:end_time]
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
      # :data=>
      #  {:box=>[0.01171875, 0.006944444444444444, 0.7671875, 0.9861111111111112],
      #   :region=>[0.0, 0.0, 1.00625, 1.788888888888889],
      #   :score=>0.70703125,
      #   :top_score=>0.70703125,
      #   :attributes=>[],
      #   :average_estimated_speed=>0,
      #   :velocity_angle=>0,
      #   :type=>"object",
      #   :max_severity=>"alert",
      #   :path_data=>
      #    [[[0.7937, 0.9986], 1758180219.920531],
      #     [[0.8008, 0.9903], 1758180220.060544],
      #     [[0.3906, 0.6347], 1758180221.52226],
      #     [[0.3977, 0.5111], 1758180221.719712],
      #     [[0.4375, 0.7778], 1758180221.911472],
      #     [[0.5852, 0.5458], 1758180222.121227],
      #     [[0.4703, 0.6389], 1758180222.332412],
      #     [[0.5312, 0.3972], 1758180222.520508],
      #     [[0.4797, 0.5556], 1758180222.722426],
      #     [[0.3977, 0.4917], 1758180223.721724],
      #     [[0.3789, 0.6319], 1758180224.052624],
      #     [[0.357, 0.7917], 1758180224.521432],
      #     [[0.3477, 0.9389], 1758180224.714737],
      #     [[0.3063, 0.9986], 1758180224.919325],
      #     [[0.3648, 0.9986], 1758180225.920606],
      #     [[0.4617, 0.9861], 1758180230.944568],
      #     [[0.5883, 0.9986], 1758180231.321145],
      #     [[0.5023, 0.9958], 1758180231.526648],
      #     [[0.7977, 0.4236], 1758180231.723018],
      #     [[0.5484, 0.7611], 1758180231.914988],
      #     [[0.4914, 0.9986], 1758180232.725217],
      #     [[0.375, 0.9986], 1758180233.51773],
      #     [[0.5109, 0.9972], 1758180245.732043],
      #     [[0.393, 0.9986], 1758180245.922063]]},
    end
  end
end
