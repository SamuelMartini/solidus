module Spree
  # Spree::NotificationEvents are events for which developers may decicde to
  # send messages (emails, texts, tweets, etc) to people or services
  # Extensions and stores that add additional events can mutate this array
  module NotificationEvents
    EVENTS = [
      :carton_shipped,
      :order_cancel,
      :order_confirm,
      :order_inventory_cancel,
      :reimbursement_processed,
    ]
  end
end
