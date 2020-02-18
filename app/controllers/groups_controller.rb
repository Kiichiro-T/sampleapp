class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  #before_action :only_executives_can_access, only: [:edit]
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
    @executives = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:executive]).each do |relationship|
      @executives << User.find(relationship.user_id)
    end
    @users = []
    GroupUser.where(group_id: @group.id).each do |relationship|
      @users << User.find(relationship.user_id)
    end
    @events = Event.where(group_id: @group.id)
  end
  
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params_for_create)
    if @group.save
      flash[:success] = "グループ作成成功！"
      # current_user.update_attributes(group_id: @group.id)
      # 後からストロングパラメータの設定をする
      redirect_to groups_url
    else
      render 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(group_params_for_update)
      flash[:success] = "グループの設定を変更しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  private

    def group_params_for_create
      params.require(:group).permit(:name, :email, :group_number,
                                    group_user_attributes: [:group_id, :user_id, :role])
    end

    def group_params_for_update
      params.require(:group).permit(:name, :email, :group_number)
    end

    # def one_user_has_one_group
    #   if current_user.group_id.present?
    #     flash[:warning] = "１ユーザーにつき１グループなので作成できません"
    #     redirect_to root_url
    #   end
    # end

    #def user_group_id_params
    #  params.require(:user).permit(:group_id)
    #end
end
