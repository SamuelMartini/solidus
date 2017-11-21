
module Spree
    module Observable
      attr_accessor :observers

      def included
        @observers = []
      end

      def add_observer(observer, func=:update)
        if @observers.nil?
          @observers = []
        end
        @observers << [observer, func]
      end

      def delete_observer(observer)
        return if @observers.nil?
        @observers.delete_if do |observer_config|
          observer_config[0] == observer
        end
      end

      def delete_observers
        return if @observers.nil?
        @observers.clear
      end

      def notify_observers(*args)
        return if @observers.nil?
        @observers.each do |observer_config|
          observer = observer_config[0]
          func = observer_config[1]
          observer.public_send(func, *args)
        end
      end

      def count_observers
        if @observers.nil?
          0
        else
          @observers.size
        end
      end
    end
end
