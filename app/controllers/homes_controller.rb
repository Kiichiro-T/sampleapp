# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def index
    @groups = Group.my_groups(current_user)
    events = Event.my_events(current_user).order(start_date: :desc)
    @events = Kaminari.paginate_array(events).page(params[:page]).per(5)
    @new_events = Event.my_events(current_user).where(created_at: (Time.now.midnight - 7.days)..Time.now.midnight).limit(5).order(created_at: :desc)
    # いずれは、Transaction.where("(creditor_id = ?) OR (debtor_id = ?)", user_id, user_id)
  end
end
