module Spree
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country_id` and `:state_id`.
    #
    # @attr_reader [Integer] country_id the ID of a Spree::Country object
    # @attr_reader [Integer] state_id the ID of a Spree::State object
    class TaxLocation
      attr_reader :country_iso, :state_iso

      # Create a new TaxLocation object
      #
      # @see Spree::Zone.for_address
      #
      # @param [Spree::Country] country a Spree::Country object, default: nil
      # @param [Spree::State] state a Spree::State object, default: nil
      #
      # @return [Spree::Tax::TaxLocation] a Spree::Tax::TaxLocation object
      def initialize(country: nil, state: nil)
        @country_iso = country && country.code
        @state_iso = state && state.code
      end

      def ==(other)
        state_iso == other.state_iso && country_iso == other.country_iso
      end

      # TODO: If we use the code here, maybe do that
      def country
        Carmen::Country.coded(country_iso)
      end

      def empty?
        country_iso.nil? && state_iso.nil?
      end
    end
  end
end
