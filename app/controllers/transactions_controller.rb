class TransactionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :confirm_definitive_registration

  def new
    #@group = Group.find(params[:group_id])
    #@event = Event.find(params[:event_id])
    #@transaction = Transaction.new
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

    # def transaction_params
    #   params.require(:transaction).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
    # end

    #def transaction_params
    #  params.require(params[:type].underscore.gsub('/', '_').to_sym).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
    #end
    # "Transaction::Event".underscore => "transaction/event"
    # "transaction/event".gsub('/', '_') => "transaction_event" 第1引数にマッチしたものを第2引数に置き換える
    # .to_sym => 文字列をシンボルに変換する
end
