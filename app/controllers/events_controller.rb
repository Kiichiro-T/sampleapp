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
    if @event.save
      flash[:success] = "イベント作成成功！"
      redirect_to group_event_url(group_id: params[:event][:group_id], id: @event.id)
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
