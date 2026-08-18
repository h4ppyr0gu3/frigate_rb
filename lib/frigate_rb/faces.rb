# frozen_string_literal: true

require_relative "types/face"
require_relative "utils"

module FrigateRb
  # Wrapper to get Frigate Events from the API
  class Faces
    extend FrigateRb::Utils

    def self.all(client: FrigateRb.client)
      response = client.get(FrigateRb::Endpoints.faces)
      parsed_response(response, FrigateRb::Types::Face, client: client)
    end

    def self.create(name, client: FrigateRb.client)
      url = FrigateRb::Endpoints.create_face(name)

      response = client.post(url)
      parsed_response(response, FrigateRb::Types::Face, client: client)
    end

    def self.register(name, file, client: FrigateRb.client)
      response = client.post_file(
        FrigateRb::Endpoints.register_face(name), file
      )
      parsed_response(response, FrigateRb::Types::Face, client: client)
    end

    def self.train(name, client: FrigateRb.client)
      response = client.get(FrigateRb::Endpoints.train_face(name))
      pp response
      parsed_response(response, FrigateRb::Types::Face, client: client)
    end
  end
end
