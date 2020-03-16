# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[index]
  def index
    @transactions = Event::Transaction.includes(:group, :event).where(debtor_id: current_user.id).order(created_at: :desc).page(params[:page]).per(5)
    @paid_total_amount = Event::Transaction.paid_total_amount(current_user)
    @unpaid_total_amount = Event::Transaction.unpaid_total_amount(current_user)
  end

  # def new
  #   @group = Group.find(params[:group_id])
  #   @event = Event.find(params[:event_id])
  #   @transaction = Transaction.new
  # end

  # def create
  #   @group = Group.find(params[:group_id])
  #   @event = Event.find(params[:event_id])
  #   @transaction = Transaction.new(transaction_params)
  #   if @transaction.save
  #     flash[:success] = 'トランザクション作成成功！'
  #     redirect_to group_event_url(group_id: @group.id, id: @event.id)
  #   else
  #     render 'new'
  #   end
  # end

  # private

  # def transaction_params
  #   params.require(:transaction).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
  # end

  # def transaction_params
  #  params.require(params[:type].underscore.gsub('/', '_').to_sym).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
  # end
  # "Transaction::Event".underscore => "transaction/event"
  # "transaction/event".gsub('/', '_') => "transaction_event" 第1引数にマッチしたものを第2引数に置き換える
  # .to_sym => 文字列をシンボルに変換する

  private

    def other_user_cannot_access
      user = User.find(params[:user_id])
      return if me?(user)

      flash[:danger] = '他のユーザーのMy収支ページにはアクセスできません'
      redirect_to root_url
    end
end
