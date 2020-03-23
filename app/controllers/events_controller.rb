# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group
  before_action :cannot_access_to_other_groups
  before_action :only_executives_can_access, except: %i[show]

  def index
    @events = Event.where(group_id: current_user_group.id).order(start_date: :desc).page(params[:page]).per(20)
  end

  def show
    @event = Event.find(params[:id])
    @attending_count = Answer.attending_count(event: @event)
    @absent_count = Answer.absent_count(event: @event)
    @unanswered_count = Answer.unanswered_count(event: @event)

    h1 = Answer.divide_answers_in_three(@event)
    @attending_answers = h1[:attending] # 出席
    @absent_answers = h1[:absent] # 欠席
    @unanswered_answers = h1[:unanswered] # 未回答

    @hash = User.unpaid_members(answers: @attending_answers, event: @event)
    @uncompleted_transactions = @hash[:uncompleted_transactions]
    @unpaid_members = @hash[:unpaid_members]
    @unpaid_members_count = @unpaid_members.count
    @total_payment = @uncompleted_transactions.sum { |h| h[:payment] }
    @expected_total_payment = @uncompleted_transactions.sum { |h| h[:debt] }
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      members = User.members(@group)
      members.delete(current_user) # イベント作成者は除く
      Event::Transaction.new_transaction_when_create_new_event(current_user, current_user, @group, @event)
      Answer.new_answer_when_create_new_event(current_user, @event)
      NewEventJob.perform_later(members, current_user, @group, @event)
      flash[:success] = 'イベントが作成されました。グループのユーザーにメールで作成を通知しました。'
      redirect_to group_event_url(group_id: @group.id, id: @event.id)
    else
      render 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    members = User.members(@group)
    if @event.update_attributes(event_params)
      UpdateEventJob.perform_later(members, current_user, @group, @event)
      flash[:success] = 'イベントの情報を更新しました'
      redirect_to group_event_url(group_id: @group.id, event_id: @event.id)
    else
      render 'edit'
    end
  end

  private

    def event_params
      params.require(:event).permit(:name, :start_date, :end_date, :answer_deadline,
                                    :description, :amount, :pay_deadline, :user_id, :group_id)
    end
end
