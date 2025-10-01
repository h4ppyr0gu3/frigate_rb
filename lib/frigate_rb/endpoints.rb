# frozen_string_literal: true

module FrigateRb
  # This class dynamically defines endpoints in case they are changed as there is no
  # versioning and should hopefully be able to see what we support at a glance
  class Endpoints
    class << self
      def config_schema = "/api/config/schema.json"
      def event(id) = "/api/events/#{id}"
      def event_clip(id) = "/api/events/#{id}/clip.mp4"
      def events = "/api/events"
      def ffprobe = "/api/ffprobe"
      def go2rtc_streams = "/api/go2rtc/streams"
      def health = "/api"
      def labels = "/api/labels"
      def login = "/api/login"
      def logs(service) = "/api/logs/#{service}"
      def metrics = "/api/metrics"
      def nvinfo = "/api/nvinfo"
      def recognized_license_plates = "/api/recognized_license_plates"
      def review(id) = "/api/reviews/#{id}"
      def reviews = "/api/reviews"
      def stats = "/api/stats"
      def vainfo = "/api/vainfo"
      def version = "/api/version"
    end
  end
end
