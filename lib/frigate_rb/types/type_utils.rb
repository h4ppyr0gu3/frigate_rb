require "time"
module FrigateRb
  module Types
    module TypeUtils
      def try_parse_date(data, key)
        return unless data[key].present?

        if data[key].is_a?(String)
          # Accept ISO8601 or HTTP-date
          Time.zone ? Time.zone.parse(data[key]) : Time.parse(data[key])
        elsif data[key].is_a?(Integer) || data[key].is_a?(Float)
          Time.at(data[key])
        end
      end

      def to_bool(value)
        case value
        when true, false then value
        when String then %w[true 1 yes y on].include?(value.strip.downcase)
        when Integer then !value.zero?
        else
          !!value
        end
      end

      def to_int(value)
        return value if value.is_a?(Integer)
        Integer(value) rescue nil
      end

      def to_float(value)
        return value if value.is_a?(Float)
        Float(value) rescue nil
      end

      def to_string(value)
        return nil if value.nil?
        value.to_s
      end

      def to_array(value)
        return [] if value.nil?
        value.is_a?(Array) ? value : [value]
      end

      def to_hash(value)
        return {} if value.nil?
        value.is_a?(Hash) ? value : {}
      end
    end
  end
end
