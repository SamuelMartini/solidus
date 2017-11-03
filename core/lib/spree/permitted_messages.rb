module Spree
  # Spree::PermittedAttributes contains the attributes permitted through strong
  # params in various controllers in the frontend. Extensions and stores that
  # need additional params to be accepted can mutate these arrays to add them.
  module PermittedMessages
    MESSAGES = {
      order_canceled: [->(*args) { Spree::OrderMailer.cancel_email(args) }],
      order_confirmed: [->(*args) { Spree::OrderMailer.confirm_email(args) }],
      order_inventory_canceled: [->(*args) { Spree::OrderMailer.inventory_cancellation_email(args) }],
      carton_shipped: [->(*args) { Spree::Config.carton_shipped_email_class.carton_shipped(args) }],
      reimbursement_processed: [->(*args) { Spree::ReimbursementMailer.reimbursement_mailer(args) }]
    }

    mattr_reader(MESSAGES)
  end
end
