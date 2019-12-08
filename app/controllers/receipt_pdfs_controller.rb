class ReceiptPdfsController < ApplicationController
  def show
    @transaction = Transaction.find_by(id: params[:id], event_id: params[:event_id])
    @user = User.find_by(id: @transaction.user_id)
    @event = Event.find_by(id: params[:event_id])
    respond_to do |format|
      format.html
      format.pdf do
        receipt_pdf = ReceiptPdf.new(@transaction, @user, @event)
        send_data receipt_pdf.render,
          filename:    'receipt.pdf',
          type:        'application/pdf',
          disposition: 'inline'
      end
    end
  end
end

