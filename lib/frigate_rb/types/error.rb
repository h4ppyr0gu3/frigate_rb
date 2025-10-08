module FrigateRb
  module Types
    class Error
      attr_reader :error, :status

      def initialize(data, status = nil)
        @error = data
        @status = status
      end
    end
  end
end
