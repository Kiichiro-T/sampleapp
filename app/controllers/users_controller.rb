class UsersController < ApplicationController
  require 'csv'

  before_action :authenticate_user!
  before_action :confirm_definitive_registration, only: [:new, :batch]

  def index
    @group = Group.find(params[:group_id])
    @users = User.where(group_id: @group.id).where(definitive_registration: false)
  end 

  def share
    group = Group.find(params[:group_id])
    users = User.where(group_id: group.id).where(definitive_registration: false)
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
    count = User.import!(params[:file], @group, params[:password])
    if count <= 0
      flash[:danger] = "データがないまたは間違いがあります。もう一度ご確認ください。"
      redirect_to new_users_url
    else
      flash[:success] = "#{count.to_s}人のユーザーを追加しました"
      redirect_to group_users_url(group_id: @group.id)
    end
  end

  private

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
