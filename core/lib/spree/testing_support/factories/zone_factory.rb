require 'spree/testing_support/sequences'

FactoryBot.define do
  factory :global_zone, class: 'Spree::Zone' do
    name 'GlobalZone'
    members []
    zone_members do |proxy|
      zone = proxy.instance_eval { @instance }
      Carmen::Country.all.map do |c|
        zone.add(c)
      end
    end
  end

  factory :zone, class: 'Spree::Zone' do
    sequence(:name) { |i| "Zone #{i}" }
    members []

    trait :with_country do
      countries { [Carmen::Country.coded('US')] }
    end
  end
end
