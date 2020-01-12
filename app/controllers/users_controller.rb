class UsersController < ApplicationController
  require 'csv'

  before_action :authenticate_user!
  before_action :confirm_definitive_registration, only: [:new, :batch]
  def index
    @users = User.all
  end 

  def new
  end

  def batch
    group = Group.find_by(id: current_user.group_id)
    if params[:file].blank?
      flash[:danger] = "読み込むファイルを選択してください"
      redirect_to new_users_url
      return
    elsif File.extname(params[:file].original_filename) != ".csv"
      flash[:danger] = "csvファイルのみ読み込み可能です"
      redirect_to new_users_url
      return
    elsif params[:password].blank?
      flash[:danger] = "パスワードを入力をしてください"
      redirect_to new_users_url
      return
    end
    count = User.import!(params[:file], group, params[:password])
    if count <= 0
      flash[:danger] = "データがないまたは間違いがあるので、もう一度ご確認ください"
      redirect_to new_users_url
    else
      flash[:success] = "#{count.to_s}人のユーザーを追加しました"
      redirect_to users_url
    end
  end

  def csv_template
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_template_csv
      end
    end
  end

  private

    def send_template_csv
      csv = CSV.generate do |csv|
        csv_column_name = %w(name)
        csv << csv_column_name
      end
      send_data(csv, filename: "一括登録用テンプレート.csv", type: 'application/csv')
    end

end
