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

  def change
    @executives = User.executives(@group)
    user_ids = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:general]).each do |relationship|
      user_ids << User.find(relationship.user_id).id
    end
    @generals = User.where(id: user_ids).order(furigana: :asc)
  end

  def inheritable_search
    keyword = params[:keyword]
    user_ids = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:general]).each do |relationship|
      user_ids << User.find(relationship.user_id).id
    end
    members = User.where(id: user_ids)
    @members = members.where('name LIKE :keyword OR furigana LIKE :keyword ', keyword: "%#{keyword.tr('ぁ-ん','ァ-ン')}%").order(furigana: :asc)
    respond_to do |format|
      format.json { render 'inheritable_members', json: @members }
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

  def assignable_search
    keyword = params[:keyword]
    user_ids = []
    GroupUser.where(group_id: @group.id, role: GroupUser.roles[:general]).each do |relationship|
      user_ids << User.find(relationship.user_id).id
    end
    members = User.where(id: user_ids)
    @members = members.where('name LIKE :keyword OR furigana LIKE :keyword ', keyword: "%#{keyword.tr('ぁ-ん','ァ-ン')}%").order(furigana: :asc)
    respond_to do |format|
      format.json { render 'inheritable_members', json: @members }
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

  def invite
    email = params[:email].try(:downcase!)
    if email.blank?
      flash[:notice] = "メールアドレスを入力してください"
      render 'edit'
    elsif user = User.find_by(email: email)
      relationship = GroupUser.new(group_id: @group.id, user_id: user.id, role: GroupUser.roles[:general])
      if relationship.save
        flash[:notice] = "招待に成功しました"
        redirect_to edit_group_url(@group)
      else
        flash[:notice] = 'そのメールアドレスはすでに招待済みです'
        render 'edit'
      end
    else
      flash[:notice] = "メールアドレスが存在しないまたは間違いがあります"
      render 'edit'
    end
  end

  private

    def set_group
      @group = Group.find(params[:id])
    end

    # １ユーザーにつき１幹事まで
    def one_user_cannot_be_some_executives
      return unless GroupUser.executive_relationship(current_user)

      flash[:danger] = '幹事は複数のグループの幹事を兼任することはできません。複数のグループの幹事である場合は新しいアカウントを作成するようにしてください。'
      raise Forbidden
    end

    def group_params
      params.require(:group).permit(:name, :email, :group_number)
    end

    def new_executive_id
      params[:new_executive].to_i
    end
end
