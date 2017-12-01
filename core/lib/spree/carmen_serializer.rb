require 'carmen'
Carmen::Region.class_eval do
  def to_hash
    { type: type, code: code, name: name, subregions: subregions, parent: parent.code }
  end
end

module Spree
  class CarmenSerializer
    def self.load(value)
      return nil if value.nil?
      thing = JSON.parse(value)
      if thing.class == Array
        thing.map do |place|
          if place['type'] == 'country'
            Carmen::Country.coded(place['code'])
          else
            Carmen::Country.coded(place['parent']).subregions.find { |p| p.code == place['code'] }
          end
        end
      else
        if thing['type'] == 'country'
          Carmen::Country.coded(thing['code'])
        else
          Carmen::Country.coded(thing['parent']).subregions.find { |s| s.code == thing['code'] }
        end
      end
    end

    def self.dump(value)
      value.to_json
    end
  end
end
