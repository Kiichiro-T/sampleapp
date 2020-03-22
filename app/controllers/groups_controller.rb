# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :one_user_cannot_be_some_executives, only: %i[new create]
  before_action :set_group, except: %i[new create]
  before_action :cannot_access_to_other_groups, except: %i[new create]
  before_action :only_executives_can_access, except: %i[new create]

  def show
    events = Event.my_events(current_user).order(start_date: :desc)
    @events = Kaminari.paginate_array(events).page(params[:page]).per(5)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      GroupUser.new_group(@group, current_user)
      flash[:success] = 'グループ作成成功！'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @executives = User.executives(@group)
    @generals = User.generals(@group)
  end

  def update
    if @group.update_attributes(group_params)
      flash[:success] = 'グループの設定を変更しました'
      redirect_to @group
    else
      render 'edit'
    end
  end

  def inherit
    executive_relationship = GroupUser.executive_relationship(@group, current_user.id)
    general_relationship = GroupUser.general_relationship(@group, new_executive_id)
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general]) && general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = '引継ぎが成功しました'
      redirect_to @group
    else
      render 'edit'
    end
  end

  def assign
    general_relationship = GroupUser.general_relationship(@group, new_executive_id)
    if general_relationship.update_attribute(:role, GroupUser.roles[:executive])
      flash[:success] = '任命に成功しました'
      redirect_to @group
    else
      render 'edit'
    end
  end

  def resign
    executive_relationship = GroupUser.executive_relationship(@group, current_user.id)
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general])
      flash[:success] = '辞任しました'
      redirect_to @group
    else
      render 'edit'
    end
  end

  def deposit
  end

  def statistics
  end

  private

    def set_group
      @group = Group.find(params[:id])
    end

    # １ユーザーにつき１幹事まで
    def one_user_cannot_be_some_executives
      return unless GroupUser.executive_relationship(current_user)

      flash[:danger] = '幹事は複数のグループの幹事を兼任することはできません。複数のグループの幹事である場合は新しいアカウントを作成するようにしてください。'
      redirect_to root_url
    end

    def group_params
      params.require(:group).permit(:name, :email, :group_number)
    end

    def new_executive_id
      params[:new_executive].to_i
    end
end
