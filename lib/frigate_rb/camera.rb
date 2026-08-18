# frozen_string_literal: true

module FrigateRb
  class Camera
    def self.latest_frame(camera_name, client: FrigateRb.client, &block)
      res = client.get(FrigateRb::Endpoints.latest_frame(camera_name))
      file = res.body

      yield file
    end
  end
end
