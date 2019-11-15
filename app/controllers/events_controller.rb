class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new]

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:succes] = "イベント作成成功！"
      redirect_to @event
    else
      render 'new'
    end
  end

  private

    def event_params
      params.require(:event).permit(:name, :user_id)
    end
end
