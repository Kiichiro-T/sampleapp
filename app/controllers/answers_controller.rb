# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_answer, only: %i[update]
  before_action :other_user_cannot_access, only: %i[update]

  # def index
  #   @transactions = Event::Transaction.all.limit(5)
  # end

  # def create
  #   event = Event.find(params[:event_id])
  #   @answer = Answer.new(answer_params)
  #   @answer.save
  #   redirect_to group_event_path(group_id: event.group_id, id: event.id)
  # end

  def change
    puts "あいあいあい#{params[:answer_id]}"
    if params[:answer_id]
      puts params[:answer_id]
      puts 'いいいいいいいいいいい'
      answer = Answer.find(params[:answer_id])
      if answer&.update(status: params[:status])
        flash.now[:success] = '回答を変更しました'
      else
        flash.now[:danger] = '回答を変更できませんでした'
      end
      render partial: 'events/answer_select', locals: { answer: answer }
    else
      puts 'ああああああああああああ'
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

    def set_answer
      @answer = Answer.find(params[:id])
    end

    def other_user_cannot_access
      event = Event.find(params[:event_id])
      answer = Answer.find_by(user_id: current_user.id, event_id: event.id)
      return if answer == @answer

      flash[:danger] = '他のユーザーの回答は変更できません'
      redirect_to root_url
    end
end
