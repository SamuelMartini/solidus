module Spree
  class EmailObserver

    class << self
      def update(state, *args)
        case state
        when :confirm
          send_confirm_email(*args)
        when :cancel
          send_cancel_email(*args)
        when :inventory_cancel
          send_inventory_cancellation_email(*args)
        when :reimbursement_process
          send_reimbursement_email(*args)
        when :shipped
          send_carton_shipped_emails(*args)
        else
          Rails.logger.error("EmailObserver does not understand a state change of #{state}")
        end
      end

      protected

      def send_confirm_email(order)
        Spree::Config.order_mailer_class.confirm_email(order).deliver_later unless order.confirmation_delivered?
        order.update_column(:confirmation_delivered, true)
      end

      def send_cancel_email(order)
        Spree::Config.order_mailer_class.cancel_email(order).deliver_later
      end

      def send_inventory_cancellation_email(order, inventory_units)
        Spree::Config.order_mailer_class.inventory_cancellation_email(order, inventory_units).deliver_later if Spree::OrderCancellations.send_cancellation_mailer
      end

      def send_reimbursement_email(id)
        Spree::Config.reimbursement_mailer_class.reimbursement_email(id).deliver_later
      end

      def send_carton_shipped_emails(carton)
        carton.orders.each do |order|
          Spree::Config.carton_shipped_email_class.shipped_email(order: order, carton: carton).deliver_later if carton.stock_location.fulfillable? # e.g. digital gift cards that aren't actually shipped
        end
      end
    end
  end
end
