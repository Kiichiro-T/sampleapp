class UsersController < ApplicationController
  before_action :authenticate_user!
  def index
    @users = User.all
  end

  def batch
    if params[:file].blank?
      flash[:error] = "読み込むファイルを選択してください"
      redirect_to new_users_url
    elsif File.extname(params[:file].original_filename) != ".csv"
      flash[:error] = "csvファイルのみ読み込み可能です"
      redirect_to new_users_url
    else
      group = Group.find_by(id: current_user.group_id)
      count = User.import(params[:file], group)
      flash[:notice] = "#{count.to_s}人のユーザーを追加しました"
      redirect_to users_url
    end
  end
end
