# frozen_string_literal: true

module FrigateRb
  class Camera
    def self.latest_frame(camera_name, &block)
      res = FrigateRb::Client.instance.get(FrigateRb::Endpoints.latest_frame(camera_name))
      file = res.body

      yield file
    end
  end
end
