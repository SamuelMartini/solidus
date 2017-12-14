module Spree
  class ZoneMember < Spree::Base
    belongs_to :zone, class_name: 'Spree::Zone', counter_cache: true, inverse_of: :zone_members
    serialize :zoneable, Spree::SerializeCarmen

    def initialize(zoneable:)
      super
      type = (zoneable.class == Carmen::Country) ? 'Spree::Country' : 'Spree::State'
      update_attributes(zoneable_type: type)
    end

    delegate :name, to: :zoneable, allow_nil: true
  end
end
