module FrigateRb
  module Types
    class Face
      attr_reader :name

      def initialize(data)
        data = data.deep_symbolize_keys

        @name = data[:name]
      end
    end
  end
end
