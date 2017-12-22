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
          spree_zone_members_table[:state_iso].in(states)
        matching_country =
          spree_zone_members_table[:state_iso].eq(nil).
          and(spree_zone_members_table[:country_iso].in(countries))
        joins(:zone_members).where(matching_state.or(matching_country)).distinct
      end
    end

    scope :for_address, ->(address) do
      if address
        # TODO: check that the thing doing this can't just take single values
        # TODO: Give an array
        with_member_ids([address.state_iso], [address.country_iso])
      else
        none
      end
    end

    alias :members :zone_members
    accepts_nested_attributes_for :zone_members, allow_destroy: true, reject_if: proc { |a| a['country_iso'].blank? }

    self.whitelisted_ransackable_attributes = ['description']

    # Returns all zones that contain any of the zone members of the zone passed
    # in. This also includes any country zones that contain the state of the
    # current zone, if it's a state zone. If the passed-in zone has members, it
    # will also be in the result set.
    def self.with_shared_members(zone)
      return none unless zone
      countries = zone.countries.map(&:code)
      states = zone.states.map(&:code)
      with_member_ids(states, countries).distinct
    end

    def kind
      if members.any? # && !members.any? { |member| member.try(:zoneable_type).nil? }
        members.last.state_iso.nil? ? 'country' : 'state'
      end
    end

    def kind=(value)
      # do nothing - just here to satisfy the form
    end

    def include?(address)
      return false unless address

      members.any? do |zone_member|
        if zone_member.state_iso.nil?
          zone_member.country == address.country
        else
          zone_member.state == address.state
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
        members.pluck(:country_iso).map { |t| Carmen::Country.coded(t) }
      else
        []
      end
    end

    def states
      if kind == 'state'
        members.pluck(:country_iso, :state_iso).map do |r|
          Carmen::Country.coded(r[0]).subregions.find { |s| s.code == r[1] }
        end
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
        if zone_members.last.state_iso.nil?
          zone_members.where('state_iso IS NOT NULL').destroy_all
        else
          zone_members.where('state_iso IS NULL').destroy_all
        end
      end
    end

    def set_zone_members(objs, type)
      zone_members.destroy_all
      objs.reject(&:blank?).map do |obj|
        member = Spree::ZoneMember.new
        member.zoneable = obj
        members << member
      end
    end
  end
end
