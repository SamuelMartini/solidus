require 'rails_helper'

describe Spree::Gateway do
  it 'is deprecated' do
    expect(Spree::Deprecation).to receive(:warn)
    described_class.new
  end

  it 'has Spree::PaymentMethod::CreditCard as superclass' do
    expect(described_class.ancestors).to include(Spree::PaymentMethod::CreditCard)
  end
end
