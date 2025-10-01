# frozen_string_literal: true

module FrigateRb
  class Info
    ENDPOINT_LIST = %i[stats vainfo health config_schema version ffprobe nvinfo
                       metrics go2rtc_streams labels recognized_license_plates].freeze

    class << self
      ENDPOINT_LIST.each do |endpoint|
        define_method endpoint do |params = {}|
          FrigateRb::Client.instance.get(FrigateRb::Endpoints.send(endpoint), params).body
        end
      end

      # service is one of :frigate, :nginx, :go2rtc
      def logs(service)
        FrigateRb::Client.instance.get(FrigateRb::Endpoints.logs(service)).body
      end
    end
  end
end
