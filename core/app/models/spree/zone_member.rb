module Spree
  class ZoneMember < Spree::Base
    belongs_to :zone, class_name: 'Spree::Zone', counter_cache: true, inverse_of: :zone_members
    # Can I just do this?
    # delegate :name, to: :zoneable, allow_nil: true

    # TODO: Do this?
    def zoneable
      state || country
    end

    def country
      Carmen::Country.coded(country_iso)
    end

    def state
      country.subregions.find { |s| s.code == state_iso }
    end

    def name
      state.try(:name) || country.name
    end

    def zoneable=(place)
      # Spree::Deprecation.warn('Initialize a zone with state: or country:')
      if place.class == Carmen::Country
        update_attributes(country_iso: place.code)
      else
        update_attributes(state_iso: place.code)
        update_attributes(country_iso: place.parent.code)
      end
    end
  end
end
