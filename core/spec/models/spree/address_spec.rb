require 'rails_helper'

RSpec.describe Spree::Address, type: :model do
  subject { Spree::Address }

  context "aliased attributes" do
    let(:address) { Spree::Address.new firstname: 'Ryan', lastname: 'Bigg' }

    it " first_name" do
      expect(address.first_name).to eq("Ryan")
    end

    it "last_name" do
      expect(address.last_name).to eq("Bigg")
    end
  end

  context "validation" do
    let(:country) { Carmen::Country.coded('US') }
    let(:state) { country.subregions.find { |s| s.name == 'Maryland' } }
    let(:address) { build(:address, country: country) }

    context 'address does not require state' do
      before do
        Spree::Config.address_requires_state = false
      end
      it "address_requires_state preference is false" do
        address.state = nil
        address.state_name = nil
        expect(address).to be_valid
      end
    end

    context 'address requires state' do
      before do
        Spree::Config.address_requires_state = true
      end

      it "state_name is not nil and country does not have any states" do
        address.state = nil
        address.state_name = 'alabama'
        expect(address).to be_valid
      end

      it "errors when state_name is nil" do
        address.state_name = nil
        address.state = nil
        expect(address).not_to be_valid
      end

      it "full state name is in state_name and country does contain that state" do
        address.state_name = 'alabama'
        # called by state_validate to set up state_id.
        # Perhaps this should be a before_validation instead?
        expect(address).to be_valid
        expect(address.state).not_to be_nil
        expect(address.state_name).to be_nil
      end

      it "state abbr is in state_name and country does contain that state" do
        address.state_name = state.code
        expect(address).to be_valid
        expect(address.state).not_to be_nil
        expect(address.state_name).to be_nil
      end

      context 'when the country does not match the state' do
        context 'when the country requires states' do
          it 'is invalid' do
            address.state = state
            address.country = Carmen::Country.coded('CA')
            address.valid?
            expect(address.errors["state"]).to eq(['is invalid', 'does not match the country'])
          end
        end

        context 'when the country does not require states' do
          it 'is invalid' do
            address.state = state
            address.country = Carmen::Country.coded('AI')
            address.valid?
            expect(address.errors["state"]).to eq(['does not match the country'])
          end
        end
      end

      # TODO: In what world would this make sense?
      # it "both state and state_name are entered but country does not contain the state" do
      #   address.state = state
      #   address.state_name = 'maryland'
      #   address.country = Carmen::Country.coded('CA')
      #   expect(address).to be_valid
      #   expect(address.state_id).to be_nil
      # end

      it "both state and state_name are entered and country does contain the state" do
        address.state = state
        address.state_name = 'maryland'
        expect(address).to be_valid
        expect(address.state_name).to be_nil
      end
    end

    it "requires phone" do
      address.phone = ""
      address.valid?
      expect(address.errors["phone"]).to eq(["can't be blank"])
    end

    it "requires zipcode" do
      address.zipcode = ""
      address.valid?
      expect(address.errors['zipcode']).to include("can't be blank")
    end

    context "phone not required" do
      before { allow(address).to receive_messages require_phone?: false }

      it "shows no errors when phone is blank" do
        address.phone = ""
        address.valid?
        expect(address.errors[:phone].size).to eq 0
      end
    end

    context "zipcode not required" do
      before { allow(address).to receive_messages require_zipcode?: false }

      it "shows no errors when zipcode is blank" do
        address.zipcode = ""
        address.valid?
        expect(address.errors[:zipcode]).to be_blank
      end
    end
  end

  context ".build_default" do
    context "no user given" do
      let!(:default_country) { Carmen::Country.coded('US') }

      context 'has a default country' do
        before do
          Spree::Config[:default_country_iso] = default_country.code
        end

        it "sets up a new record with Spree::Config[:default_country_iso]" do
          expect(Spree::Address.build_default.country).to eq default_country
        end
      end

      # Regression test for https://github.com/spree/spree/issues/1142
      it "raises ActiveRecord::RecordNotFound if :default_country_iso is set to an invalid value" do
        Spree::Config[:default_country_iso] = "00"
        expect {
          Spree::Address.build_default.country
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context '.factory' do
    context 'with attributes that use setters defined in Address' do
      let(:address_attributes) { attributes_for(:address, country: nil, country_iso: country.code) }
      let(:country) { Carmen::Country.coded('ZW') }

      it 'uses the setters' do
        expect(subject.factory(address_attributes).country).to eq(country)
      end
    end
  end

  context ".immutable_merge" do
    RSpec::Matchers.define :be_address_equivalent_attributes do |expected|
      fields_of_interest = [:firstname, :lastname, :company, :address1, :address2, :city, :zipcode, :phone, :alternative_phone]
      match do |actual|
        expected_attrs = expected.symbolize_keys.slice(*fields_of_interest)
        actual_attrs = actual.symbolize_keys.slice(*fields_of_interest)
        expected_attrs == actual_attrs
      end
    end

    let(:new_address_attributes) { attributes_for(:address) }
    subject { Spree::Address.immutable_merge(existing_address, new_address_attributes) }

    context "no existing address supplied" do
      let(:existing_address) { nil }

      context 'and there is not a matching address in the database' do
        it "returns new Address matching attributes given" do
          expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
        end
      end

      context 'and there is a matching address in the database' do
        let(:new_address_attributes) { Spree::Address.value_attributes(matching_address.attributes) }
        let!(:matching_address) { create(:address, firstname: 'Jordan') }

        it "returns the matching address" do
          expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
          expect(subject.id).to eq(matching_address.id)
        end
      end
    end

    context "with existing address" do
      let(:existing_address) { create(:address) }

      it "returns a new Address of merged data" do
        merged_attributes = subject.attributes.merge(new_address_attributes.symbolize_keys)
        expect(subject.attributes).to be_address_equivalent_attributes merged_attributes
        expect(subject.id).not_to eq existing_address.id
      end

      context "and no changes to attributes" do
        let(:new_address_attributes) { existing_address.attributes }

        it "returns existing address" do
          expect(subject).to eq existing_address
          expect(subject.id).to eq existing_address.id
        end
      end

      context 'and changed address matches an existing address' do
        let(:new_address_attributes) { Spree::Address.value_attributes(matching_address.attributes) }
        let!(:matching_address) { create(:address, firstname: 'Jordan') }

        it 'returns the matching address' do
          expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
          expect(subject.id).to eq(matching_address.id)
        end
      end
    end
  end

  describe '.value_attributes' do
    subject do
      Spree::Address.value_attributes(base_attributes, merge_attributes)
    end

    context 'with symbols and strings' do
      let(:base_attributes) { { 'address1' => '1234 way', 'address2' => 'apt 2' } }
      let(:merge_attributes) { { address1: '5678 way' } }

      it 'stringifies and merges the keys' do
        expect(subject).to eq('address1' => '5678 way', 'address2' => 'apt 2')
      end
    end

    context 'with database-only attributes' do
      let(:base_attributes) do
        {
          'id' => 1,
          'created_at' => Time.current,
          'updated_at' => Time.current,
          'address1' => '1234 way'
        }
      end
      let(:merge_attributes) do
        {
          'updated_at' => Time.current,
          'address2' => 'apt 2'
        }
      end

      it 'removes the database-only addresses' do
        expect(subject).to eq('address1' => '1234 way', 'address2' => 'apt 2')
      end
    end

    context 'with aliased attributes' do
      let(:base_attributes) { { 'first_name' => 'Jordan' } }
      let(:merge_attributes) { { 'last_name' => 'Brough' } }

      it 'renames them to the normalized value' do
        expect(subject).to eq('firstname' => 'Jordan', 'lastname' => 'Brough')
      end

      it 'does not modify the original hashes' do
        subject
        expect(base_attributes).to eq('first_name' => 'Jordan')
        expect(merge_attributes).to eq('last_name' => 'Brough')
      end
    end
  end

  describe '.taxation_attributes' do
    context 'both taxation and non-taxation attributes are present ' do
      let(:country) { Carmen::Country.coded('US') }
      let(:state) { country.subregions.first }
      let(:address) { Spree::Address.new firstname: 'Michael', lastname: 'Jackson', state: state, country: country, zipcode: '12345' }

      it 'removes the non-taxation attributes' do
        expect(address.taxation_attributes).not_to eq('firstname' => 'Michael', 'lastname' => 'Jackson')
      end

      it 'returns only the taxation attributes' do
        expect(address.taxation_attributes).to eq('state' => state, 'country' => country, 'zipcode' => '12345')
      end
    end

    context 'taxation attributes are blank' do
      let(:address) { Spree::Address.new firstname: 'Michael', lastname: 'Jackson' }

      it 'returns a subset of the attributes with the correct keys and nil values' do
        expect(address.taxation_attributes).to eq('state' => nil, 'country' => nil, 'zipcode' => nil)
      end
    end
  end

  context '#country_iso=' do
    let(:address) { build(:address, country: nil) }
    let(:country) { Carmen::Country.coded('ZW') }

    it 'sets the country to the country with the matching iso code' do
      address.country_iso = country.code
      expect(address.country).to eq(country)
    end

    it 'raises an exception if the iso is not found' do
      expect {
        address.country_iso = "NOCOUNTRY"
      }.to raise_error(::ActiveRecord::RecordNotFound, "Couldn't find Spree::Country")
    end
  end

  context '#full_name' do
    context 'both first and last names are present' do
      let(:address) { Spree::Address.new firstname: 'Michael', lastname: 'Jackson' }
      specify { expect(address.full_name).to eq('Michael Jackson') }
    end

    context 'first name is blank' do
      let(:address) { Spree::Address.new firstname: nil, lastname: 'Jackson' }
      specify { expect(address.full_name).to eq('Jackson') }
    end

    context 'last name is blank' do
      let(:address) { Spree::Address.new firstname: 'Michael', lastname: nil }
      specify { expect(address.full_name).to eq('Michael') }
    end

    context 'both first and last names are blank' do
      let(:address) { Spree::Address.new firstname: nil, lastname: nil }
      specify { expect(address.full_name).to eq('') }
    end
  end

  context '#state_text' do
    context 'state is blank' do
      let(:address) { Spree::Address.new state: nil, state_name: 'virginia' }
      specify { expect(address.state_text).to eq('virginia') }
    end

    context 'state is not blank' do
      let(:state) { Carmen::Country.coded('US').subregions.find { |s| s.name == 'Virginia' } }
      let(:address) { Spree::Address.new state: state }
      specify { expect(address.state_text).to eq('VA') }
    end
  end

  context '#requires_phone' do
    subject { described_class.new }

    it { is_expected.to be_require_phone }
  end
end
