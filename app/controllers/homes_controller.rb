# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def index
    @my_groups = Group.my_groups(current_user)
    today = Time.current.midnight
    @events = Event.my_events(current_user).where('start_date >= ?', today).order(start_date: :asc).limit(5)
    @new_events = Event.my_events(current_user).where(created_at: (Time.now.midnight - 7.days)..Time.now.midnight).limit(5).order(created_at: :desc)
    # いずれは、Transaction.where("(creditor_id = ?) OR (debtor_id = ?)", user_id, user_id)
  end
end
