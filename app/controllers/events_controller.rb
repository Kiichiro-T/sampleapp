class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration

  def index
    @group = Group.find(params[:group_id])
    @events = Event.where(user_id: current_user.id)
  end

  def show
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:id])
    @transactions = Transaction.where(group_id: @group.id, event_id: @event.id)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    group = Group.find(@event.group_id)
    users = []
    GroupUser.where(group_id: group.id).each do |relationship|
      user = User.find(relationship.user_id)
      unless user == current_user
        users << user
      end
    end
    if @event.save
      users.each do |user|
        NotificationMailer.send_when_make_new_event(user, current_user, group, @event).deliver
        Event::Transaction.create!(
          deadline: @event.pay_deadline,
          debt: @event.amount,
          payment: 0,
          creditor_id: current_user.id,
          debtor_id: user.id,
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

  private

    def event_params
      params.require(:event).permit(:name, :start_date, :end_date, :amount,
                                    :description, :pay_deadline, :user_id, :group_id)
    end
end
