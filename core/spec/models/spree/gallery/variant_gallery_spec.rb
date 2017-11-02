require 'rails_helper'
require 'spree/testing_support/shared_examples/gallery'

RSpec.describe Spree::Gallery::VariantGallery do
  let(:gallery) { described_class.new(variant) }
  let(:variant) { Spree::Variant.new }

  shared_context 'has multiple images' do
    let(:first_image) { build(:image) }
    let(:second_image) { build(:image) }

    before do
      variant.images << first_image
      variant.images << second_image
    end
  end

  it_behaves_like 'a gallery'
end
