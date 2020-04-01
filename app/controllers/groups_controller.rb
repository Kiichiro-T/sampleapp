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
  end

  def inheritable_search
    incremental_search('inheritable_members')
  end

  def inherit
    @executives = User.executives(@group)
    return flash_and_render(key: :danger, message: '引継ぎたい人を選択してください', action: 'change') if params[:new_executive].blank?

    return flash_and_render(key: :danger, message: '選択した人はすでに他のグループの幹事です。本人にご確認ください', action: 'change') if new_executive.blank?

    if GroupUser.inherit(group: @group, current_user: current_user, new_executive: new_executive)
      flash_and_redirect(key: :success, message: '引継ぎが成功しました', redirect_url: root_url)
    else
      flash_and_render(key: :danger, message: 'エラーが発生しました。', action: 'change')
    end
  end

  def assignable_search
    incremental_search('assignable_members')
  end

  def assign
    @executives = User.executives(@group)
    return flash_and_render(key: :danger, message: '任命したい人を選択してください', action: 'change') if params[:new_executive].blank?

    return flash_and_render(key: :danger, message: '選択した人はすでに他のグループの幹事です。本人にご確認ください', action: 'change') if new_executive.blank?

    general_relationship = GroupUser.general_relationship(group: @group, user: new_executive)
    if general_relationship.update(role: GroupUser.roles[:executive])
      flash_and_redirect(key: :success, message: '任命に成功しました', redirect_url: root_url)
    else
      flash_and_render(key: :danger, message: 'エラーが発生しました。', action: 'change')
    end
  end

  def resign
    executive_relationship = GroupUser.executive_relationship(group: @group, user: current_user)
    if executive_relationship.update_attribute(:role, GroupUser.roles[:general])
      flash_and_redirect(key: :success, message: '辞任しました', redirect_url: root_url)
    else
      flash_and_render(key: :danger, message: 'エラーが発生しました。', action: 'change')
    end
  end

  def deposit
  end

  def statistics
  end

  def invite
    @executives = User.executives(@group)
    email = params[:email].try(:downcase)
    return flash_and_render(key: :danger, message: "メールアドレスを入力してください", action: 'change') if email.blank?

    if user = User.find_by(email: email)
      relationship = GroupUser.new(group_id: @group.id, user_id: user.id, role: GroupUser.roles[:general])
      if relationship.save
        NotificationMailer.invite(group: @group, user: user, current_user: current_user).deliver_later
        flash_and_redirect(key: :success, message: "招待に成功しました", redirect_url: change_group_url(@group))
      else
        flash_and_render(key: :danger, message: 'そのメールアドレスはすでに招待済みです', action: 'change')
      end
    else
      flash_and_render(key: :danger, message: "メールアドレスは登録されていないまたは間違いがあります", action: 'change')
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

    def new_executive
      user_id = params[:new_executive].to_i
      if GroupUser.where(user_id: user_id, role: GroupUser.roles[:executive]).present?
        nil
      else
        User.find(user_id)
      end
    end

    def incremental_search(partial)
      keyword = params[:keyword]
      user_ids = []
      GroupUser.where(group_id: @group.id, role: GroupUser.roles[:general]).each do |relationship|
        user_ids << User.find(relationship.user_id).id
      end
      members = User.where(id: user_ids)
      @members = members.where('name LIKE :keyword OR furigana LIKE :keyword ', keyword: "%#{keyword.tr('ぁ-ん','ァ-ン')}%").order(furigana: :asc)
      respond_to do |format|
        format.json { render partial, json: @members }
      end
    end
end
