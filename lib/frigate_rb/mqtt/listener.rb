require "mqtt"

module FrigateRb
  module Mqtt
    class Listener
      def self.run(&block)
        mqtt_link = 
        client = MQTT::Client.connect(mqtt_uri)
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

      def self.mqtt_uri
# mqtt[s]://[username][:password]@host.domain[:port]
        auth = ""
        if FrigateRb.configuration.frigate_mqtt_username.present? &&  FrigateRb.configuration.frigate_mqtt_username.present?
          auth = "#{FrigateRb.configuration.frigate_mqtt_username}:#{FrigateRb.configuration.frigate_mqtt_password}@"
        end

        # handle mqtts in future
        host_and_port = FrigateRb.configuration.frigate_mqtt_url.gsub("mqtt://", "")

        "mqtt://#{auth}#{host_and_port}}"
      end
    end
  end
end
