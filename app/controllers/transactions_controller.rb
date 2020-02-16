class TransactionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :confirm_definitive_registration

  def new
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new
  end

  def create
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:event_id])
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      flash[:success] = "トランザクション作成成功！"
      redirect_to group_event_url(group_id: @group.id, id: @event.id)
    else
      render 'new'
    end
  end

  private

    def transaction_params
      params.require(:transaction).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
    end
end
