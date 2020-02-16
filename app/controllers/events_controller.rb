class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration

  def index
    @user = User.find(current_user.id)
    @events = Event.where(user_id: @user.id)
  end

  def show
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:id])
    @transactions = Transaction.where(group_id: @group.id, event_id: @event.id)
  end

  def new
    @group = Group.find(params[:group_id])
    @event = Event.new
  end

  def create
    @group = Group.find(params[:group_id])
    @event = Event.new(event_params)
    if @event.save
      flash[:success] = "イベント作成成功！"
      redirect_to group_event_url(group_id: @group.id, id: @event.id)
    else
      render 'new'
    end
  end

  private

    def event_params
      params.require(:event).permit(:name, :user_id, :group_id)
    end
end
