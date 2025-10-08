module FrigateRb
  module Types
    module TypeUtils
      def try_parse_date(data, key)
        return unless data[key].present?

        if data[key].is_a?(String)
          Date.parse(data[key])
        elsif data[key].is_a?(Integer) || data[key].is_a?(Float)
          Time.at(data[key])
        end
      end
    end
  end
end
