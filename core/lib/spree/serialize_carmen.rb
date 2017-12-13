module Spree
  class SerializeCarmen
    def self.load(value)
      return nil if value.nil?
      thing = JSON.parse(value)
      if thing.class == Array
        thing.map do |place|
          next nil if place.nil?
          if place['type'] == 'country'
            Carmen::Country.coded(place['code'])
          else
            Carmen::Country.coded(place['parent']).subregions.find { |p| p.code == place['code'] }
          end
        end.compact
      else
        if thing['type'] == 'country'
          Carmen::Country.coded(thing['code'])
        elsif thing['type'] == 'state'
          Carmen::Country.coded(thing['parent']).subregions.find { |s| s.code == thing['code'] }
        else
          nil
        end
      end
    end

    def self.dump(value)
      value.to_json
    end
  end
end
