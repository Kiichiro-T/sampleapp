# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group
  before_action :cannot_access_to_other_groups
  before_action :set_group_for_current_executive

  def index
    @events = Event.where(user_id: current_user.id)
  end

  def show
    @event = Event.find(params[:id])
    @group = Group.find(params[:group_id])
    @executives = User.executives(@group)
    @answer = Answer.find_by(user_id: current_user.id, event_id: @event.id)
    # 支払い済みと未払いに分ける
    h1 = Event::Transaction.divide_transaction_in_two(@event)
    @completed_transactions = h1[:completed] # 支払い済み
    @uncompleted_transactions = h1[:uncompleted] # 未払い

    # 回答済みと未回答に分ける
    h2 = Answer.divide_answers_in_three(@event)
    @attending_answers = h2[:attending] # 出席
    @absent_answers = h2[:absent] # 欠席
    @unanswered_answers = h2[:unanswered] # 未回答
    @count = User.members(@group).count
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      members = User.members(@group)
      members.delete(current_user) # イベント作成者は除く
      Answer.new_answer_when_create_new_event(current_user, @event)
      members.each do |member|
        NewEventJob.perform_later(member, current_user, @group, @event)
        NotificationMailer.send_when_make_new_event(member, current_user, @group, @event).deliver_later(wait: 1.minute)
      end
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
      members.each do |member|
        UpdateEventJob.perform_later(member, current_user, @group, @event)
        NotificationMailer.send_when_update_event(member, current_user, @group, @event).deliver_later(wait: 1.minute)
      end
      flash[:success] = 'イベントの情報を更新しました'
      redirect_to group_event_url(group_id: @group.id, event_id: @event.id)
    else
      render 'edit'
    end
  end

  private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def event_params
      params.require(:event).permit(:name, :start_date, :end_date, :answer_deadline,
                                    :description, :amount, :pay_deadline, :user_id, :group_id)
    end
end
