require 'rails_helper'

RSpec.describe Spree::Zone, type: :model do
  describe 'for_address' do
    let(:canada) { Carmen::Country.coded('CA') }
    let(:country) { Carmen::Country.coded('US') }
    let(:state) { country.subregions.find { |state| state.code == 'NY' } }
    let(:new_york_address) { create(:address, state: state) }
    let(:alabama_address) { create(:address) }
    let(:canada_address) { create(:address, country: canada, state: canada.subregions.first) }

    let!(:new_york_zone) { create(:zone, members: [new_york_address.state]) }
    let!(:alabama_zone) { create(:zone, members: [alabama_address.state]) }
    let!(:united_states_zone) { create(:zone, members: [new_york_address.country]) }
    let!(:canada_zone) { create(:zone, members: [canada_address.country]) }
    let!(:north_america_zone) { create(:zone, members: [canada_address.country, new_york_address.country]) }
    subject { Spree::Zone.for_address(address) }

    context 'when there is no address' do
      let(:address) { nil }
      it 'returns an empty relation' do
        expect(subject).to eq([])
      end
    end

    context 'for an address in New York' do
      let(:address) { new_york_address }

      it 'matches the New York zone' do
        expect(subject).to include(new_york_zone)
      end

      it 'matches the United States zone' do
        expect(subject).to include(united_states_zone)
      end

      it 'does not match the Alabama zone' do
        expect(subject).not_to include(alabama_zone)
      end

      it 'does not match the Canadian zone' do
        expect(subject).not_to include(canada_zone)
      end

      it 'matches the North America zone' do
        expect(subject).to include(north_america_zone)
      end
    end
  end

  context "#country_list" do
    let(:country) { Carmen::Country.coded('US') }
    let(:state) { country.subregions.first }

    context "when zone consists of countries" do
      let(:country_zone) { create(:zone, name: 'CountryZone', members: []) }

      before { country_zone.add(country) }

      it 'should return a list of countries' do
        Spree::Deprecation.silence do
          expect(country_zone.country_list).to eq([country])
        end
      end
    end

    context "when zone consists of states" do
      let(:state_zone) { create(:zone, name: 'StateZone', members: []) }

      before { state_zone.add(state) }

      it 'should return a list of countries' do
        Spree::Deprecation.silence do
          expect(state_zone.country_list).to eq([state.parent])
        end
      end
    end
  end

  context "#include?" do
    let(:country) { Carmen::Country.coded('US') }
    let(:state) { country.subregions.first }
    let(:address) { create(:address, state: state) }

    context "when zone is country type" do
      let(:country_zone) { create(:zone, name: 'CountryZone', members: []) }
      before { country_zone.add(country) }

      it "should be true" do
        expect(country_zone.include?(address)).to be true
      end
    end

    context "when zone is state type" do
      let(:state_zone) { create(:zone, name: 'StateZone', members: []) }
      before { state_zone.add(state) }

      it "should be true" do
        expect(state_zone.include?(address)).to be true
      end
    end
  end

  context "#save" do
    context "when a zone member country is added to an existing zone consisting of state members" do
      it "should remove existing state members" do
        zone = create(:zone, name: 'foo', members: [])
        country = Carmen::Country.coded('US')
        state = country.subregions.first
        zone.add(state)
        zone.add(country)
        zone.save
        expect(zone.reload.members).to eq([country])
      end
    end
  end

  context "#kind" do
    let(:country) { Carmen::Country.coded('US') }
    let(:state) { country.subregions.first }

    context "when the zone consists of country zone members" do
      before do
        @zone = create(:zone, name: 'country', zone_members: [])
        @zone.add(country)
      end
      it "should return the kind of zone member" do
        expect(@zone.kind).to eq("country")
      end
    end

    context "when the zone consists of state zone members" do
      before do
        @zone = create(:zone, name: 'state', zone_members: [])
        @zone.add(state)
      end
      it "should return the kind of zone member" do
        expect(@zone.kind).to eq("state")
      end
    end
  end

  context "state and country associations" do
    let!(:country) { Carmen::Country.coded('US') }

    context "has countries associated" do
      let!(:zone) do
        create(:zone, countries: [country])
      end

      it "can access associated countries" do
        expect(zone.countries).to eq([country])
      end
    end

    context "has states associated" do
      let!(:state) { country.subregions.first }
      let!(:zone) do
        create(:zone, countries: [state])
      end

      it "can access associated states" do
        expect(zone.states).to eq([state])
      end
    end
  end

  context ".with_shared_members" do
    let!(:country)  { Carmen::Country.coded('US') }
    let!(:country2) { Carmen::Country.coded('CA') }
    let!(:country3) { Carmen::Country.coded('IT') }

    subject(:zones_with_shared_members) { Spree::Zone.with_shared_members(zone) }

    context 'when passing a zone with no members' do
      let!(:zone) { create :zone }

      it 'will return an empty set' do
        expect(subject).to eq([])
      end
    end

    context 'when passing nil' do
      let!(:zone) { nil }

      it 'will return an empty set' do
        expect(subject).to eq([])
      end
    end

    context "finding potential matches for a country zone" do
      let!(:zone) do
        create(:zone).tap do |z|
          z.add(country)
          z.add(country2)
          z.save!
        end
      end

      let!(:zone2) do
        create(:zone).tap { |z| z.add(country) && z.save! }
      end

      let!(:zone3) do
        create(:zone).tap { |z| z.add(country3) && z.save! }
      end

      it "will find all zones with countries covered by the passed in zone" do
        expect(zones_with_shared_members).to include(zone, zone2)
      end

      it "will not return zones with countries not covered in the passed in zone" do
        expect(zones_with_shared_members).not_to include(zone3)
      end

      it "only returns each zone once" do
        expect(zones_with_shared_members.select { |z| z == zone }.size).to be 1
      end
    end

    context "finding potential matches for a state zone" do
      let!(:state)  { country.subregions.first }
      let!(:state2) { country2.subregions.first }
      let!(:state3) { country2.subregions.first }
      let!(:zone) do
        create(:zone).tap do |z|
          z.add(state)
          z.add(state2)
          z.save!
        end
      end
      let!(:zone2) do
        create(:zone).tap { |z| z.add(state) && z.save! }
      end
      let!(:zone3) do
        create(:zone).tap { |z| z.add(state2) && z.save! }
      end

      it "will find all zones which share states covered by passed in zone" do
        expect(zones_with_shared_members).to include(zone, zone2)
      end

      it "will find zones that share countries with any states of the passed in zone" do
        expect(zones_with_shared_members).to include(zone3)
      end

      it "only returns each zone once" do
        expect(zones_with_shared_members.select { |z| z == zone }.size).to be 1
      end
    end
  end
end
