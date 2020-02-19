class AnswersController < ApplicationController

  def create
    event = Event.find(params[:event_id])
    @answer = Answer.new(answer_params)
    if @answer.save
      redirect_to group_event_path(group_id: event.group_id, id: event.id)
    else
      redirect_to group_event_path(group_id: event.group_id, id: event.id)
    end
  end

  def update
    event = Event.find(params[:event_id])
    @answer = Answer.find_by(user_id: current_user.id, event_id: event.id)
    if @answer.update_attributes(answer_params)
      redirect_to group_event_path(group_id: event.group_id, id: event.id)
    else
      redirect_to group_event_path(group_id: event.group_id, id: event.id)
    end
  end

  private

    def answer_params
      params.require(:answer).permit(:status, :user_id, :event_id)
    end

end
