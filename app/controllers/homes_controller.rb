# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def index
    user = current_user
    @my_groups = Group.my_groups(user)
    today = Time.current.midnight
    @events = Event.my_events(user).where('start_date >= ?', today).order(start_date: :asc).limit(5)
    @new_events = Event.my_events(user).where(created_at: (today - 7.days)..today.end_of_day).limit(4).order(created_at: :asc)
    @total_payment = Transaction.total_payment_by_user(user)
    all_debts = Transaction.where(completed: false, debtor_id: user.id)
    unpaid_debts = all_debts.where('deadline <= ?', Time.current.end_of_day)
    @total_unpaid_debt = unpaid_debts.sum('debt') - unpaid_debts.sum('payment')
    expected_debts = all_debts.where('deadline >= ?', Time.current.end_of_day)
    @total_expected_debt = expected_debts.sum('debt') - expected_debts.sum('payment')
    @urgent_expected_debts = expected_debts.order(deadline: :asc).limit(2)
  end
end
