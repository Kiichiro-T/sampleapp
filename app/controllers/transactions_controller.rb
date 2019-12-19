class TransactionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def new
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new
  end

  def create
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      flash[:success] = "トランザクション作成成功！"
      redirect_to event_url(id: @event.id)
    else
      render 'new'
    end
  end

  private

    def transaction_params
      params.require(:transaction).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
    end
end
