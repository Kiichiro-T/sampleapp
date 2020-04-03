# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group, except: %i[list]
  before_action :cannot_access_to_other_groups, except: %i[list]
  before_action :cannot_access_to_other_user_page, only: %i[list]
  before_action :only_executives_can_access, except: %i[show list]

  def index
    @events = Event.where(group_id: current_user_group.id).order(start_date: :desc).page(params[:page]).per(10)
  end

  def list
    user = User.find(params[:user_id])
    group_ids = []
    Group.my_groups(user).each do |group|
      group_ids << group.id
    end
    @events = Event.where(group_id: group_ids).order(start_date: :desc).page(params[:page]).per(10)
  end

  def show
    @event = Event.find(params[:id])
    @attending_count = Answer.attending_count(event: @event)
    @absent_count = Answer.absent_count(event: @event)
    @unanswered_count = Answer.unanswered_count(event: @event)

    h1 = Answer.divide_answers_in_three(@event)
    @attending_answers = h1[:attending].page(params[:page]).per(10) # 出席
    @absent_answers = h1[:absent].page(params[:page]).per(10) # 欠席
    @unanswered_answers = h1[:unanswered].page(params[:page]).per(10) # 未回答

    @hash = User.unpaid_members(answers: @attending_answers, event: @event)
    @uncompleted_transactions = Kaminari.paginate_array(@hash[:uncompleted_transactions]).page(params[:page]).per(10)
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
    if @event.update(event_params)
      UpdateEventJob.perform_later(members: members, current_user: current_user, group: @group, event: @event)
      flash_and_redirect(key: :success, message: 'イベント情報を更新しました', redirect_url: group_event_url(group_id: @group.id, id: @event.id))
    else
      render 'edit'
    end
  end

  private

    def event_params
      params.require(:event).permit(:name, :start_date, :end_date, :answer_deadline,
                                    :description, :comment, :amount,
                                    :pay_deadline, :user_id, :group_id)
    end

    def cannot_access_to_other_user_page
      return if current_user.id == params[:user_id].to_i

      flash[:danger] = 'アクセス権限がありません'
      raise Forbidden
    end
end
