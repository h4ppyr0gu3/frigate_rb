require "mqtt"

module FrigateRb
  module Mqtt
    class Listener
      def self.run(&block)
        client = MQTT::Client.connect(FrigateRb.configuration.frigate_mqtt_url)
        topic = ENV.fetch("MQTT_TOPIC", "frigate/#")
        client.subscribe(topic)
        client.get do |topic, message|
          case topic
          when "frigate/events"
            parsed_message = JSON.parse(message)
            mqtt_event = ::FrigateRb::Types::MqttEvent.new(parsed_message)
            yield "event", mqtt_event
          when "frigate/reviews"
            parsed_message = JSON.parse(message)
            yield "review", parsed_message
          else
            yield topic, message
          end
        end
      end
    end
  end
end
