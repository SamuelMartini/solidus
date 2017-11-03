require 'rails_helper'

module TestMailer
  class << self
    attr_accessor :no_args_received
    attr_accessor :args

    def no_args
      @no_args_received = true
    end

    def with_args(args)
      @args = args
    end
  end
end

RSpec.describe Spree::Dispatcher do
  it 'does not die when receiving a bogus message name' do
    expect{Spree::Dispatcher.send_message(:completely_fake_message_name)}.not_to raise_error
  end

  context 'sends message' do
    before do
      Spree::PermittedMessages::MESSAGES[:test_no_args] = [['TestMailer', 'no_args']]
      Spree::PermittedMessages::MESSAGES[:test_args] = [['TestMailer', 'with_args']]
      TestMailer.no_args_received = false
    end

    it 'sends to configured receivers' do
      expect{Spree::Dispatcher.send_message(:test_no_args)}.not_to raise_error
      expect(TestMailer.no_args_received).to eq true
    end

    it 'sends along arguments to receivers' do
      expect{Spree::Dispatcher.send_message(:test_args, 2)}.not_to raise_error
      expect(TestMailer.args).to eq 2
    end
  end
end
