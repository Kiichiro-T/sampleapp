class UsersController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = User.all
  end

  def batch
    group = Group.find_by(id: current_user.group_id)
    User.import(params[:file], group)
    redirect_to users_url
  end
end
