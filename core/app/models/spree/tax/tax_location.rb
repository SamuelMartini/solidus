module Spree
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country` and `:state`.
    #
    # @attr_reader [Integer] a Carmen::Country object
    # @attr_reader [Integer] a Carmen::Region object
    class TaxLocation
      attr_reader :country, :state

      # Create a new TaxLocation object
      #
      # @see Spree::Zone.for_address
      #
      # @param [Spree::Country] country a Carmen::Country object, default: nil
      # @param [Spree::State] state a Carmen::Region object, default: nil
      #
      # @return [Spree::Tax::TaxLocation] a Spree::Tax::TaxLocation object
      def initialize(country: nil, state: nil)
        @country = country
        @state = state
      end

      def ==(other)
        state == other.state && country == other.country
      end

      def empty?
        country.nil? && state.nil?
      end
    end
  end
end
