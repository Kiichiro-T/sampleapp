class UsersController < ApplicationController
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
    end
    if File.extname(params[:file].original_filename) != ".csv"
      flash[:danger] = "csvファイルのみ読み込み可能です"
      redirect_to new_users_url
      return
    end
    count = User.import!(params[:file], group)
    if count <= 0
      flash[:danger] = "データがないまたは間違いがあるので、もう一度ご確認ください"
      redirect_to new_users_url
    else
      flash[:success] = "#{count.to_s}人のユーザーを追加しました"
      redirect_to users_url
    end
  end
end
