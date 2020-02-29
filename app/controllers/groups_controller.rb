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
    @executives = executives(@group)
    @generals = generals(@group)
    @events = Event.where(group_id: @group.id)
  end
  
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
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
    @executives = executives(@group)
    @generals = generals(@group)
  end

  def update
    if @group.update_attributes(group_params)
      flash[:success] = "グループの設定を変更しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def inherit
    executive_relationship = executive_relationship(@group, current_user.id)
    general_relationship = general_relationship(@group, new_executive_id)
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general]) && general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = "引継ぎが成功しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def assign
    general_relationship = general_relationship(@group, new_executive_id)
    if general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = "任命に成功しました"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def resign
    executive_relationship = executive_relationship(@group, current_user.id)
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

    # １ユーザーにつき１幹事まで
    def one_user_cannot_be_some_executives
      relationship = GroupUser.find_by(user_id: current_user.id, role: GroupUser.roles[:executive])
      if relationship
        current_executive_group = Group.find(relationship.group_id)
        if current_executive_group
          flash[:danger] = "幹事は複数のグループの幹事を兼任することはできません。複数のグループの幹事である場合は新しいアカウントを作成するようにしてください。"
          redirect_to root_url
        end
      end
    end

    def group_params
      params.require(:group).permit(:name, :email, :group_number)
    end

    def new_executive_id
      params[:new_executive].to_i
    end

    def general_relationship(group, user_id)
      GroupUser.find_by(group_id: group.id, user_id: user_id, role: GroupUser.roles[:general])
    end

    def executive_relationship(group, user_id)
      GroupUser.find_by(group_id: group.id, user_id: user_id, role: GroupUser.roles[:executive])
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
