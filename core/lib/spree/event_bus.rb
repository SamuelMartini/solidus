module Spree
  class EventBus
    include Singleton

    def initialize
      @subscriptions = Hash.new { |hash, key| hash[key] = [] }
    end

    def publish(name, event)
      @subscriptions[name].each do |subscription_proc|
        subscription_proc.call(event)
      end
    end

    def subscribe(name, proc_to_call)
      subscription = @subscriptions[name]
      already_subbed = subscription.any? { |sub_proc| sub_proc == proc_to_call }
      subscription << proc_to_call unless already_subbed
    end

    def subscriber_count(name)
      @subscriptions[name].size
    end

    def clear_subscribers(name)
      @subscriptions[name].clear
    end
  end
end
