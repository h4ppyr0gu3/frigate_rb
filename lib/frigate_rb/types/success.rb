module FrigateRb
  module Types
    class Success
      attr_reader :message, :success

      def initialize(data, client: nil)
        @message = data[:message]
        @success = data[:success]
      end
    end
  end
end
