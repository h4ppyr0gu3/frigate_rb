module FrigateRb
  module Types
    class Success
      attr_reader :message, :success

      def initialize(data)
        @message = data[:message]
        @success = data[:success]
      end
    end
  end
end
