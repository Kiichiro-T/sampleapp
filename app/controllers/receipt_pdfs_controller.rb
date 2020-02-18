class ReceiptPdfsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_for_current_executive
  def show
    event = Event.find(params[:event_id])
    group = Group.find(event.group_id)
    transaction = Transaction.find_by(event_id: event.id, url_token: params[:url_token])
    debtor = User.find(transaction.debtor_id)
    respond_to do |format|
      format.html
      format.pdf do
        receipt_pdf = ReceiptPdf.new(debtor, event, transaction)
        send_data receipt_pdf.render,
          filename:    'receipt.pdf',
          type:        'application/pdf',
          disposition: 'inline'
      end
    end
  end
end

