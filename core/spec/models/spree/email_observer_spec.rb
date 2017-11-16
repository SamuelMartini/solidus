require 'rails_helper'

RSpec.describe Spree::EmailObserver do
  let(:observer) { Spree::EmailObserver }
  let(:order) { create(:order) }

  RSpec.shared_examples 'sends the correct email' do |method|
    it 'sends the email' do
      mail_double = double
      expect(mailer).to receive(method).with(*args).and_return(mail_double)
      expect(mail_double).to receive(:deliver_later)
      subject
    end
  end

  describe '#update' do
    context ':confirm' do
      subject { observer.update(:confirm, order) }

      include_examples 'sends the correct email', :confirm_email do
        let(:mailer) { Spree::Config.order_mailer_class }
        let(:args) { [order] }
      end

      it 'sets confirmation delivered' do
        expect(order.confirmation_delivered?).to be false
        subject
        expect(order.confirmation_delivered?).to be true
      end
    end

    context ':confirm but a confirmation email has already been sent' do
      it 'does not send duplicate confirmation emails' do
        allow(order).to receive_messages(confirmation_delivered?: true)
        expect(Spree::OrderMailer).not_to receive(:confirm_email)
        subject
      end
    end

    context ':cancel' do
      subject { observer.update(:cancel, order) }

      include_examples 'sends the correct email', :cancel_email do
        let(:mailer) { Spree::Config.order_mailer_class }
        let(:args) { [order] }
      end
    end

    context ':inventory_cancel' do
      subject { observer.update(:inventory_cancel, order, []) }

      include_examples 'sends the correct email', :inventory_cancellation_email do
        let(:mailer) { Spree::Config.order_mailer_class }
        let(:args) { [order, []] }
      end
    end

    context ':reimbursement_process' do
      let(:reimbursement) { create(:reimbursement) }
      subject { observer.update(:reimbursement_process, reimbursement.id) }

      include_examples 'sends the correct email', :reimbursement_email do
        let(:mailer) { Spree::Config.reimbursement_mailer_class }
        let(:args) { [reimbursement.id] }
      end
    end

    context ':shipped' do
      let(:carton) { create(:carton) }
      subject { observer.update(:shipped, carton) }

      include_examples 'sends the correct email', :shipped_email do
        let(:mailer) { Spree::Config.carton_shipped_email_class }
        let(:args) { [order: carton.orders.first, carton: carton] }
      end
    end
  end
end
