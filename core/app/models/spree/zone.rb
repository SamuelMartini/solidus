Carmen::Region.class_eval do
  def to_hash
    { type: type, code: code, name: name, subregions: subregions, parent: parent.code }
  end
end

module Spree
  class CarmenSerializer
    def self.load(value)
      return nil if value.nil?
      JSON.parse(value).map do |place|
        if place['type'] == 'country'
          Carmen::Country.coded(place['code'])
        else
          Carmen::Country.coded(place['parent']).subregions.find { |p| p.code == place['code'] }
        end
      end
    end

    def self.dump(value)
      value.to_json
    end
  end

  class Zone < Spree::Base
    has_many :tax_rates, dependent: :destroy, inverse_of: :zone

    serialize :members, Spree::CarmenSerializer

    def add(place)
      members.push(place)
    end

    has_many :shipping_method_zones, dependent: :destroy
    has_many :shipping_methods, through: :shipping_method_zones

    validates :name, presence: true, uniqueness: { allow_blank: true }
    before_save :remove_defunct_members

    def countries
      members.select { |member| member.class == Carmen::Country }
    end

    def states
      members.select { |member| member.class == Carmen::Region }
    end

    scope :with_member_ids, ->(states, countries) do
      if states.empty? && countries.empty?
        none
      else
        Spree::Zone.all.select do |zone|
          if zone.countries.any?
            (zone.countries & countries).any? ||
              zone.countries.any? { |country| (country.subregions & states).any? }
          elsif zone.states.any?
            (zone.states & states).any?
          else
            none
          end
        end
      end
    end

    scope :for_address, ->(address) do
      if address
        with_member_ids([address.state], [address.country])
      else
        none
      end
    end

    # alias :members :zone_members
    # accepts_nested_attributes_for :zone_members, allow_destroy: true, reject_if: proc { |a| a['zoneable_id'].blank? }

    self.whitelisted_ransackable_attributes = ['description']

    # Returns all zones that contain any of the zone members of the zone passed
    # in. This also includes any country zones that contain the state of the
    # current zone, if it's a state zone. If the passed-in zone has members, it
    # will also be in the result set.
    def self.with_shared_members(zone)
      return none unless zone
      countries = zone.countries
      states = zone.states

      with_member_ids(states, countries).uniq
    end


    def kind
      if members.any?
        members.last.class == Carmen::Country ? 'country' : 'state'
      end
    end

    def kind=(value)
      # do nothing - just here to satisfy the form
    end

    def include?(address)
      return false unless address
      members.any? do |zone_member|
        if zone_member.class == Carmen::Country
          zone_member == address.country
        else
          zone_member == address.state
        end
      end
    end

    def zone_members=(places)
      members = places
    end

    # convenience method for returning the countries contained within a zone
    def country_list
      case kind
      when 'country' then countries
      when 'state' then states.collect { |member| member.parent }
      else []
      end.flatten.compact.uniq
    end

    def <=>(other)
      name <=> other.name
    end

    # All zoneables belonging to the zone members.  Will be a collection of either
    # countries or states depending on the zone type.
    # TODO: I don't think this is used
    def zoneables
      if countries.empty?
        states
      else
        countries
      end
    end

    private

    def remove_defunct_members
      if members.any?
        delete_country = members.last.class == Carmen::Region
        if delete_country
          members.reject! { |member| member.class == Carmen::Country }
        else
          members.reject! { |member| member.class == Carmen::Region }
        end
      end
    end
  end
end
