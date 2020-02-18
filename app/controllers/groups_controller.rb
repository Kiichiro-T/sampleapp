class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_for_current_executive
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
    @generals = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:general]).each do |relationship|
      @generals << User.find(relationship.user_id)
    end
    @events = Event.where(group_id: @group.id)
  end
  
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params_for_create)
    if @group.save
      GroupUser.create(
        group_id: @group.id,
        user_id: current_user.id,
        role: GroupUser.roles[:executive]
      )
      flash[:success] = "グループ作成成功！"
      # current_user.update_attributes(group_id: @group.id)
      # 後からストロングパラメータの設定をする
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
    @generals = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:general]).each do |relationship|
      @generals << User.find(relationship.user_id)
    end
    @executives = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:executive]).each do |relationship|
      @executives << User.find(relationship.user_id)
    end
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

  def inherit
    group = Group.find(params[:id])
    new_executive_id = params[:new_executive].to_i
    executive_relationship = GroupUser.find_by(group_id: group.id, user_id: current_user.id, role: GroupUser.roles[:executive])
    general_relationship = GroupUser.find_by(group_id: group.id, user_id: new_executive_id, role: GroupUser.roles[:general])
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general]) && general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = "引継ぎが成功しました"
      redirect_to group
    else
      render 'edit'
    end
  end

  def assign
    group = Group.find(params[:id])
    new_executive_id = params[:new_executive].to_i
    general_relationship = GroupUser.find_by(group_id: group.id, user_id: new_executive_id, role: GroupUser.roles[:general])
    if general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = "任命が成功しました"
      redirect_to group
    else
      render 'edit'
    end
  end

  private

    def group_params_for_create
      params.require(:group).permit(:name, :email, :group_number)
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
