class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :one_user_cannot_be_some_executives, only: [:new]
  before_action :set_group, only: [:show, :edit, :update, :inherit, :assign, :resign]
  before_action :cannot_access_to_other_groups, only: [:show, :edit, :update, :inherit, :assign, :resign]
  before_action :set_group_for_current_executive
  #before_action :only_executives_can_access, only: [:edit]
  def index
    @groups = Group.all
  end

  def show
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
    if @group.update_attributes(group_params_for_update)
      flash[:success] = "グループの設定を変更しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def inherit
    new_executive_id = params[:new_executive].to_i
    executive_relationship = GroupUser.find_by(group_id: @group.id, user_id: current_user.id, role: GroupUser.roles[:executive])
    general_relationship = GroupUser.find_by(group_id: @group.id, user_id: new_executive_id, role: GroupUser.roles[:general])
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general]) && general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = "引継ぎが成功しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def assign
    new_executive_id = params[:new_executive].to_i
    general_relationship = GroupUser.find_by(group_id: @group.id, user_id: new_executive_id, role: GroupUser.roles[:general])
    if general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = "任命に成功しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def resign
    executive_relationship = GroupUser.find_by(group_id: @group.id, user_id: current_user.id, role: GroupUser.roles[:executive])
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general])
      flash[:success] = "辞任しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  private

    def set_group
      @group = Group.find(params[:id])
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      groups = []
      GroupUser.where(user_id: current_user.id).each do |relationship|
        groups << Group.find(relationship.group_id)
      end
      unless groups.include?(@group)
        flash[:danger] = "不正な操作です。"
        redirect_to root_url
      end
    end

    # １ユーザーにつき１幹事まで
    def one_user_cannot_be_some_executives
      relationship = GroupUser.find_by(user_id: current_user.id, role: GroupUser.roles[:executive])
      if relationship
        @current_executive_group = Group.find(relationship.group_id)
        if @current_executive_group
          flash[:danger] = "幹事は複数のグループの幹事を兼任することはできません。複数のグループの幹事である場合は新しいアカウントを作成するようにしてください。"
          redirect_to root_url
        end
      end
    end

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
