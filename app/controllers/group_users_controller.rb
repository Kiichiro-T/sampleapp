class GroupUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_for_current_executive

  def inherit
    group = Group.find(pamras[:id])
    inherited_executives = params[:inherited_executives]
    @group_user = GroupUser.find_by(group_id: @group_id, user_id: current_user.id, role: GroupUser.roles[:executive])
  end

  def appoint
  end

  def resign
  end
end
