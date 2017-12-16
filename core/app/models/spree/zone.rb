module Spree
  class Zone < Spree::Base
    has_many :zone_members, dependent: :destroy, class_name: "Spree::ZoneMember", inverse_of: :zone
    has_many :tax_rates, dependent: :destroy, inverse_of: :zone

    has_many :shipping_method_zones, dependent: :destroy
    has_many :shipping_methods, through: :shipping_method_zones

    validates :name, presence: true, uniqueness: { allow_blank: true }
    after_save :remove_defunct_members

    scope :with_member_ids, ->(states, countries) do
      if !states.present? && !countries.present?
        none
      else
        spree_zone_members_table = Spree::ZoneMember.arel_table
        matching_state =
          spree_zone_members_table[:zoneable_type].eq("Spree::State").
          and(spree_zone_members_table[:zoneable].in(states))
        matching_country =
          spree_zone_members_table[:zoneable_type].eq("Spree::Country").
          and(spree_zone_members_table[:zoneable].in(countries))
        joins(:zone_members).where(matching_state.or(matching_country)).distinct
      end
    end

    scope :for_address, ->(address) do
      if address
        # TODO: check that the thing doing this can't just take single values
        # TODO: Give an array
        with_member_ids([address.state], [address.country])
      else
        none
      end
    end

    alias :members :zone_members
    accepts_nested_attributes_for :zone_members, allow_destroy: true, reject_if: proc { |a| a['zoneable'].blank? }

    self.whitelisted_ransackable_attributes = ['description']

    # Returns all zones that contain any of the zone members of the zone passed
    # in. This also includes any country zones that contain the state of the
    # current zone, if it's a state zone. If the passed-in zone has members, it
    # will also be in the result set.
    def self.with_shared_members(zone)
      return none unless zone
      countries = zone.countries
      states = zone.states
      with_member_ids(states, countries).distinct
    end

    def kind
      if members.any? && !members.any? { |member| member.try(:zoneable_type).nil? }
        members.last.zoneable_type.demodulize.underscore
      end
    end

    def kind=(value)
      # do nothing - just here to satisfy the form
    end

    def include?(address)
      return false unless address

      members.any? do |zone_member|
        case zone_member.zoneable_type
        when 'Spree::Country'
          zone_member.zoneable == address.country
        when 'Spree::State'
          zone_member.zoneable == address.state
        else
          false
        end
      end
    end

    # convenience method for returning the countries contained within a zone
    def country_list
      @countries ||= case kind
                     when 'country' then zoneables
                     when 'state' then zoneables.collect(&:parent)
                     else []
                     end.flatten.compact.uniq
    end

    def <=>(other)
      name <=> other.name
    end

    # All zoneables belonging to the zone members.  Will be a collection of either
    # countries or states depending on the zone type.
    def zoneables
      members.map(&:zoneable)
    end

    def countries
      if kind == 'country'
        members.pluck(:zoneable)
      else
        []
      end
    end

    def states
      if kind == 'state'
        members.pluck(:zoneable)
      else
        []
      end
    end

    def countries=(carmens)
      set_zone_members(carmens, 'Spree::Country')
    end

    def states=(carmens)
      set_zone_members(carmens, 'Spree::State')
    end

    private

    def remove_defunct_members
      if zone_members.any?
        zone_members.where('zoneable IS NULL OR zoneable_type != ?', "Spree::#{kind.classify}").destroy_all
      end
    end

    def set_zone_members(objs, type)
      zone_members.destroy_all
      objs.reject(&:blank?).map do |obj|
        member = Spree::ZoneMember.new
        member.zoneable_type = type
        member.zoneable = obj
        members << member
      end
    end
  end
end
