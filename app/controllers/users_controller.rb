class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group, only: [:new, :batch]
  before_action :cannot_access_to_other_groups, only: [:new, :batch]
  before_action :set_group_for_current_executive
  # before_action :only_executives_can_access, only: [:new]
  require 'csv'

  before_action :authenticate_user!
  before_action :confirm_definitive_registration

  def index
    # 必要なくなる
    @group = Group.find(params[:group_id])
    @users = []
    GroupUser.where(group_id: @group.id).each do |relationship|
      user = User.find(relationship.user_id)
      if user.definitive_registration == false 
        @users << user
      end
    end
    # @users = User.where(group_id: @group.id).where(definitive_registration: false)
  end 

  def show
    @groups = Group.my_groups(current_user)
  end

  def share
    group = Group.find(params[:group_id])
    users = []
    GroupUser.where(group_id: group.id).each do |relationship|
      user = User.find(relationship.user_id)
      if user.definitive_registration == false
        users << user
      end
    end
    # users = User.where(group_id: group.id).where(definitive_registration: false)
    respond_to do |format|
      format.html
      format.csv do |csv|
        share_csv(users)
      end
    end
  end

  def new
    @group = Group.find(params[:group_id])
  end

  def csv_template
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_template_csv
      end
    end
  end

  def batch
    @group = Group.find(params[:group_id])
    if params[:file].blank?
      flash[:danger] = "読み込むファイルを選択してください。"
      redirect_to new_users_url
      return
    elsif File.extname(params[:file].original_filename) != ".csv"
      flash[:danger] = "csvファイルのみ読み込み可能です。"
      redirect_to new_users_url
      return
    elsif params[:password].blank?
      flash[:danger] = "パスワードを入力をしてください。"
      redirect_to new_users_url
      return
    end
    users = User.import!(params[:file], @group, params[:password])
    count = users.count
    if count <= 0
      flash[:danger] = "データがないまたは間違いがあります。もう一度ご確認ください。"
      redirect_to new_users_url
    else
      users.each do |user|
        NotificationMailer.send_when_batch_registration(user, current_user).deliver
      end
      # メールを送信中がわかるアニメーションが欲しい
      flash[:success] = "#{count.to_s}人のユーザーを追加し通知メールを送信しました。"
      redirect_to group_users_url(group_id: @group.id)
    end
  end

  private

    def set_group
      @group = Group.find(params[:group_id])
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      groups = Group.my_groups(current_user)
      unless groups.include?(@group)
        flash[:danger] = "不正な操作です。"
        redirect_to root_url
      end
    end

    def send_template_csv
      # bom = "\uFEFF"
      csv = CSV.generate(force_quotes: true, encoding: Encoding::SJIS) do |csv|
        header = %w(名前 メールアドレス)
        csv << header
      end
      send_data(csv, filename: "template.csv", type: 'application/csv')
    end

    def share_csv(users)
      # bom = "\uFEFF"
      csv = CSV.generate(force_quotes: true, encoding: Encoding::SJIS) do |csv|
        header = %w(名前 メールアドレス)
        csv << header

        users.each do |user|
          values = [user.name, user.email]
          csv << values
        end
      end
      send_data(csv, filename: "share.csv", type: 'application/csv')
    end

end
