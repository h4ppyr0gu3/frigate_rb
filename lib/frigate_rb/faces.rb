# frozen_string_literal: true

require_relative "types/face"
require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Events from the API
  class Faces
    extend FrigateRb::Utils

    def self.all
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.faces)
      parsed_response(response, FrigateRb::Types::Face)
    end

    def self.create(name)
      url = FrigateRb::Endpoints.create_face(name)

      response = FrigateRb::Client.instance.post(FrigateRb::Endpoints.create_face(name))
      parsed_response(response, FrigateRb::Types::Face)
    end

    def self.register(name, file)
      response = FrigateRb::Client.instance.post_file(
        FrigateRb::Endpoints.register_face(name), file
      )
      parsed_response(response, FrigateRb::Types::Face)
    end

    def self.train(name)
      response = FrigateRb::Client.instance.get(FrigateRb::Endpoints.train_face(name))
      pp response
      parsed_response(response, FrigateRb::Types::Face)
    end
  end
end
