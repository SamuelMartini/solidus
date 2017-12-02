module Spree
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country` and `:state`.
    # NO!!!!!! TODO
    #
    # @attr_reader [Carmen::Country] country a Carmen::Country object
    # @attr_reader [Carmen::Region] state a Carmen::Region object
    class TaxLocation
      attr_accessor :country, :state

      deprecate :country_id, 'Use #country instead', deprcator: Spree::Deprecation
      deprecate :state_id, 'Use #state instead', deprcator: Spree::Deprecation

      # Create a new TaxLocation object
      #
      # @see Spree::Zone.for_address
      #
      # @param [Carmen::Country] country a Carmen::Country object, default: nil
      # @param [Carmen::Region] state a Carmen::Region object, default: nil
      #
      # @return [Spree::Tax::TaxLocation] a Spree::Tax::TaxLocation object
      def initialize(country: nil, state: nil)
        # A carmen country is passed in
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
