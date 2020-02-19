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
    @executives = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:executive]).each do |relationship|
      @executives << User.find(relationship.user_id)
    end
    @answer = Answer.find_by(user_id: current_user.id, event_id: @event.id)
    if @answer.blank?
      @answer = Answer.new
    end
    @completed_transactions = []   # 支払い済み
    @uncompleted_transactions = [] # 未払い
    Event::Transaction.where(event_id: @event.id).each do |transaction|
      if transaction.debt == transaction.payment
        @completed_transactions << transaction
      else
        @uncompleted_transactions << transaction
      end
    end
    answers = @event.answers
    @attending_answers = answers.where(status: "attending")
    @absent_answers = answers.where(status: "absent")
    members = []
    GroupUser.where(group_id: @group.id).each do |relationship|
      members << User.find(relationship.user_id)
    end
    @count = members.count
    answers.each do |answer|
      members.reject!{|member| member == User.find(answer.user_id)}
    end
    @unanswered_members = members
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    members = []
    GroupUser.where(group_id: group.id).each do |relationship|
      members << User.find(relationship.user_id)
    end
    if @event.save
      members.each do |member|
        NotificationMailer.send_when_make_new_event(member, current_user, group, @event).deliver
        Event::Transaction.create!(
          deadline: @event.pay_deadline,
          debt: @event.amount,
          payment: 0,
          creditor_id: current_user.id,
          debtor_id: member.id,
          group_id: group.id,
          event_id: @event.id,
          url_token: SecureRandom.hex(10)
        )
      end
      flash[:success] = "イベントが作成されました。グループのユーザーにメールで作成を通知しました。"
      redirect_to group_event_url(group_id: group.id, id: @event.id)
    else
      render 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    members = []
    GroupUser.where(group_id: @group.id).each do |relationship|
      members << User.find(relationship.user_id)
    end
    if @event.update_attributes(event_params)
      members.each do |member|
        NotificationMailer.send_when_update_event(member, current_user, @group, @event).deliver
        transaction = Transaction.find_by(group_id: @group.id, event_id: @event.id, debtor_id: member.id)
        transaction.update_attributes(
          deadline: @event.pay_deadline,
          debt: @event.amount,
          creditor_id: current_user.id,
          debtor_id: member.id,
          url_token: SecureRandom.hex(10)
        )
      end
      flash[:success] = "イベントの情報を更新しました"
      redirect_to group_event_url(group_id: @group.id, event_id: @event.id)
    else
      render 'edit'
    end
  end

  private

    def set_group
      @group = Group.find(params[:group_id])
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      groups = []
      GroupUser.where(user_id: current_user.id).each do |relationship|
        groups << Group.find(relationship.group_id)
      end
      unless groups.include?(@group)
        flash[:danger] = "不正な操作です。"
        redirect_to root_url
      end
    end

    def event_params
      params.require(:event).permit(:name, :start_date, :end_date, :amount,
                                    :description, :pay_deadline, :user_id, :group_id)
    end
end
