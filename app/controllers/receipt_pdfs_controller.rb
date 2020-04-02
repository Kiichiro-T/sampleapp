# frozen_string_literal: true

class ReceiptPdfsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  # 支払えてなかったら(後で実装？)
  def show
    transaction = Transaction.find_by(url_token: params[:url_token])
    @event = Event.find(transaction.event_id)
    debtor = User.find(transaction.debtor_id)
    respond_to do |format|
      format.html
      format.pdf do
        receipt_pdf = ReceiptPdf.new(debtor, @event, transaction)
        send_data receipt_pdf.render,
                  filename: 'receipt.pdf',
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end
end
