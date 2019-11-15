class TransactionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def new
    @event = Event.find_by(params[:event_id])
    @transaction = Transaction.new
  end

  def create
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      flash[:succes] = "トランザクション作成成功！"
      redirect_to event_url(id: @event.id)
    else
      render 'new'
    end
  end

  private

    def transaction_params
      params.require(:transaction).permit(:user_id, :event_id, :debtor, :deadline, :debt, :repayment)
    end
end
