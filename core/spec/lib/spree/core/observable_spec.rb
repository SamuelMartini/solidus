require 'spree/core/observable'

$called = false

class TestObservable
  include Spree::Observable
end
RSpec.describe Spree::Observable do

  context 'observable' do
    subject { TestObservable.new }

    it 'will exist' do
      expect(subject).not_to eq(nil)
    end

    it 'can handle having notify_observers called without adding an observer' do
      expect{ subject.notify_observers }.not_to raise_error
    end

    it 'has 0 observers' do
      expect(subject.count_observers).to eq 0
    end
  end

  context 'add observers' do
    subject { TestObservable.new }
    let(:observer) { ->(*args) { $called = true } }

    before do
      subject.add_observer(observer, :call)
    end

    after do
      subject.delete_observers
    end

    it 'has 1 observer' do
      expect(subject.count_observers).to eq(1)
    end
  end

  context 'observers are notified' do
    subject { TestObservable.new }
    let(:observer) { ->(*args) { $called = true } }

    before do
      $called = false
      subject.add_observer(observer, :call)
      subject.notify_observers
    end

    after do
      $called = false
      subject.delete_observers
    end

    it 'observer has been called' do
      expect($called).to eq(true)
    end
  end

  context 'notify_observers called with args' do
    subject { TestObservable.new }
    before do
      subject.delete_observers
    end
    after do
      subject.delete_observers
    end
    it 'observer gets args' do
      received_args = nil
      obs = ->(args) { received_args = args }
      subject.add_observer(obs, :call)
      subject.notify_observers(1)
      expect(received_args).to eq(1)
    end
  end

  context 'multiple observers' do
    subject { TestObservable.new }
    before do
      subject.delete_observers
    end

    after do
      subject.delete_observers
    end

    it 'all are notified' do
      called1 = false
      called2 = false
      observer1 = -> { called1 = true }
      observer2 = -> { called2 = true }

      subject.add_observer(observer1, :call)
      subject.add_observer(observer2, :call)
      subject.notify_observers

      expect(called1).to eq(true)
      expect(called2).to eq(true)
    end
  end

  context 'delete_observers' do
    subject { TestObservable.new }

    it 'can delete observers successfully' do
      observer = -> { $called = true }
      subject.add_observer(observer, :call)
      expect(subject.count_observers).to eq(1)
      subject.delete_observers
      expect(subject.count_observers).to eq(0)
    end

    it 'can delete a single observer' do
      observer = -> { $called = true }
      observer2 = -> { $called = true }
      subject.add_observer(observer, :call)
      subject.add_observer(observer2, :call)
      expect(subject.count_observers).to eq(2)
      subject.delete_observer(observer)
      expect(subject.count_observers).to eq(1)
      subject.delete_observer(observer2)
      expect(subject.count_observers).to eq(0)
    end
  end
end
