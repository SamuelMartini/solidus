module Spree
  # Spree::PermittedAttributes contains the attributes permitted through strong
  # params in various controllers in the frontend. Extensions and stores that
  # need additional params to be accepted can mutate these arrays to add them.
  module PermittedMessages
    MESSAGES = {
      order_canceled: [['Spree:OrderMailer','cancel_email']]
    }

    mattr_reader(MESSAGES)
  end
end
