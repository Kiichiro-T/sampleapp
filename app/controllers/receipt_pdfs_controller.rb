class ReceiptPdfsController < ApplicationController
  def index
    respond_to do |format|
      format.pdf do
        receipt_pdf = ReceiptPdf.new
        #receipt_pdf.font "app/assets/fonts/ipaexm.ttf" # 明朝体
        send_data receipt_pdf.render,
          filename:    'receipt.pdf',
          type:        'application/pdf',
          disposition: 'inline' # 画面に表示
      end
    end
  end
end

