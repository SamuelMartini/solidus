module Spree
  class ZoneMember < Spree::Base
    belongs_to :zone, class_name: 'Spree::Zone', counter_cache: true, inverse_of: :zone_members
    serialize :zoneable, Spree::SerializeCarmen

    before_save :set_type

    def set_type
      type = (zoneable.class == Carmen::Country) ? 'Spree::Country' : 'Spree::State'
      self[:zoneable_type] = type
    end
    # def zoneable=(thing)
    #   self[:zoneable] = thing
    # end

    # def initialize(zoneable:, zone: nil)
    #   super
    #   require 'pry'
    #   binding.pry
    #   type = (zoneable.class == Carmen::Country) ? 'Spree::Country' : 'Spree::State'
    #   update_attributes(zoneable: zoneable, zoneable_type: type)
    # end

    delegate :name, to: :zoneable, allow_nil: true
  end
end
