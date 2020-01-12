class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :one_user_has_one_group, only: [:new, :create]
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
  end
  
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:success] = "グループ作成成功！"
      current_user.update_attributes(group_id: @group.id)
      # 後からストロングパラメータの設定をする
      redirect_to groups_url
    else
      render 'new'
    end
  end

  private

    def group_params
      params.require(:group).permit(:name, :leader_id, :email)
    end

    def one_user_has_one_group
      if current_user.group_id.present?
        flash[:warning] = "１ユーザーにつき１グループなので作成できません"
        redirect_to root_url
      end
    end

    #def user_group_id_params
    #  params.require(:user).permit(:group_id)
    #end
end
