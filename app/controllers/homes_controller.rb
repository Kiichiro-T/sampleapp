class HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  def index
    @relationships = GroupUser.where(user_id: current_user.id)
    @executive_relationships = GroupUser.where(user_id: current_user.id, role: GroupUser.roles[:executives])
    @events = []
    @relationships.each do |relationship|
      Event.where(group_id: relationship.group_id).each do |event|
        @events << event
      end
    end
    user_id = current_user.id
    @transactions = Transaction.where("(creditor_id = ?) OR (debtor_id = ?)", user_id, user_id)
  end
end
