require 'spec_helper'
require 'spree/testing_support/factories/image_factory' # whuat is this?

RSpec.describe 'image factory' do
  let(:factory_class) { Spree::Image }

  describe 'plain adjustment' do
    let(:factory) { :image }

    it_behaves_like 'a working factory'
  end
end
