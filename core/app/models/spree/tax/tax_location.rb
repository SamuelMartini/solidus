module Spree
  module Tax
    # A class exclusively used as a drop-in replacement for a default tax address.
    # It responds to `:country_id` and `:state_id`.
    #
    # @attr_reader [Integer] country_id the ID of a Spree::Country object
    # @attr_reader [Integer] state_id the ID of a Spree::State object
    class TaxLocation
      attr_reader :country_id, :state_id
      attr_reader :country, :state

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
        @country_id = country && country.alpha_2_code
        @state_id = state && state.code
      end

      def ==(other)
        state_id == other.state_id && country_id == other.country_id
      end

      def empty?
        country_id.nil? && state_id.nil? && country.nil? && state.nil?
      end
    end
  end
end
