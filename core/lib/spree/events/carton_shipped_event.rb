module Spree
  module Events
    class CartonShippedEvent
      attr_reader :carton, :suppress_mailer

      def initialize(carton:, suppress_mailer: false)
        @carton = carton
        @suppress_mailer = suppress_mailer
      end
    end
  end
end
