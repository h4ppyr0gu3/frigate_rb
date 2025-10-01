module FrigateRb
  module Types
    class MqttEvent
      attr_reader :before, :after

      def initialize(data)
        data = data.deep_symbolize_keys
        @before = FrigateRb::Types::Event.new(data[:before])
        @after = FrigateRb::Types::Event.new(data[:after])
      end
    end
  end
end
