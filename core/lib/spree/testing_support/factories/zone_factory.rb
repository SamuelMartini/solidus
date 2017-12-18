require 'spree/testing_support/sequences'

FactoryBot.define do
  factory :global_zone, class: 'Spree::Zone' do
    name 'GlobalZone'
    zone_members do |proxy|
      zone = proxy.instance_eval { @instance }
      Carmen::Country.all.map do |c|
        Spree::ZoneMember.create(zoneable: c, zone: zone)
      end
    end
  end

  factory :zone, class: 'Spree::Zone' do
    sequence(:name) { |i| "Zone #{i}" }

    # If this is called multiple times it should actually return different
    # countries!!
    trait :with_country do
      countries { [Carmen::Country.coded('US')] }
    end
  end
end
