# frozen_string_literal: true

class AnswersController < ApplicationController
  def index
    @transactions = Event::Transaction.all.limit(5)
  end

  def create
    event = Event.find(params[:event_id])
    @answer = Answer.new(answer_params)
    @answer.save
    redirect_to group_event_path(group_id: event.group_id, id: event.id)
  end

  def update
    event = Event.find(params[:event_id])
    @answer = Answer.find_by(user_id: current_user.id, event_id: event.id)
    @answer.update_attributes(answer_params)
    redirect_to group_event_path(group_id: event.group_id, id: event.id)
  end

  private

    def answer_params
      params.require(:answer).permit(:status, :user_id, :event_id)
    end
end
