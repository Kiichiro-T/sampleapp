class GroupsController < ApplicationController
  
  def index
    @groups = Group.all
  end
  
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:success] = "グループ作成成功！"
      redirect_to groups_url
    else
      render 'new'
    end
  end

  private

    def group_params
      params.require(:group).permit(:name, :leader_id, :email)
    end
end
