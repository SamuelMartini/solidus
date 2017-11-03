module Spree
  # Spree::PermittedAttributes contains the attributes permitted through strong
  # params in various controllers in the frontend. Extensions and stores that
  # need additional params to be accepted can mutate these arrays to add them.
  module PermittedMessages
    MESSAGES = {
      order_canceled: [['Spree::OrderMailer','cancel_email']],
      order_confirmed: [['Spree::OrderMailer', 'confirm_email']],
      order_inventory_canceled: [['Spree::OrderMailer', 'inventory_cancellation_email']],
      carton_shipped: [['Spree::Config.carton_shipped_email_class', 'shipped_email']],
      reimbursement_processed: [['Spree::ReimbursementMailer', 'reimbursement_mailer']]
    }

    mattr_reader(MESSAGES)
  end
end
