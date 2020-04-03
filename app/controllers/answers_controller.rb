# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[update]

  def change
    if params[:answer_id]
      answer = Answer.find(params[:answer_id])
      if answer&.update(status: params[:status])
        flash.now[:success] = '回答を変更しました'
      else
        flash.now[:danger] = '回答を変更できませんでした'
      end
      render partial: 'events/answer_select', locals: { answer: answer }
    end
  end

  def update
    @answer.update_attributes(answer_params)
    redirect_to group_event_path(group_id: event.group_id, id: event.id)
  end

  private

    def answer_params
      params.require(:answer).permit(:status, :user_id, :event_id)
    end

    def other_user_cannot_access
      answer = Answer.find(params[:id])
      event = Event.find(params[:event_id])
      my_answer = Answer.find_by(user_id: current_user.id, event_id: event.id)
      return if my_answer == answer

      flash[:danger] = 'アクセス権限がありません'
      raise Forbidden
    end
end
