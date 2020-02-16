class ReceiptPdfsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def show
    group = Group.find(params[:group_id])
    event = Event.find(params[:event_id])
    transaction = Transaction.find_by(group_id: group.id, event_id: event.id, id: params[:id])
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

