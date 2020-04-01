# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group, only: %i[index new batch]
  before_action :cannot_access_to_other_groups, only: %i[new batch]
  before_action :only_executives_can_access, only: %i[new batch]
  require 'csv'

  def index
    @members = User.members_by_grade(group: @group, grade: User.grades[:grade1])
  end

  def share
    group = Group.find(params[:group_id])
    users = []
    GroupUser.where(group_id: group.id).each do |relationship|
      user = User.find(relationship.user_id)
      users << user unless user.definitive_registration
    end
    # users = User.where(group_id: group.id).where(definitive_registration: false)
    respond_to do |format|
      format.html
      format.csv do
        share_csv(users)
      end
    end
  end

  def new
  end

  def csv_template
    respond_to do |format|
      format.html
      format.csv do
        send_template_csv
      end
    end
  end

  def batch
    if params[:file].blank?
      message_and_redirect('ファイルを選択してください。')
      return
    elsif File.extname(params[:file].original_filename) != '.csv'
      message_and_redirect('csvファイルのみ読み込み可能です。')
      return
    elsif params[:password].blank?
      message_and_redirect('パスワードを入力してください。')
      return
    end

    hash = User.import!(file: params[:file], group: @group, password: params[:password])
    if hash[:status] == 'success'
      added_users = hash[:added_users]
      added_count = hash[:added_count]
      if added_count <= 0
        message_and_redirect('データがありません')
      else
        added_users.each do |user|
          NotificationMailer.send_when_batch_registration(user, current_user).deliver_later(wait: 1.minute)
        end
        flash[:success] = "#{added_count}人のユーザーを追加し通知メールを送信しました。"
        redirect_to edit_group_url(@group)
      end
    else
      message_and_redirect(hash[:error_message])
    end
  end

  private

    def send_template_csv
      # bom = "\uFEFF"
      csv = CSV.generate(force_quotes: true, encoding: Encoding::SJIS) do |c|
        header = %w[名前 メールアドレス]
        c << header
      end
      send_data(csv, filename: 'template.csv', type: 'application/csv')
    end

    def share_csv(users)
      # bom = "\uFEFF"
      csv = CSV.generate(force_quotes: true, encoding: Encoding::SJIS) do |c|
        header = %w[名前 メールアドレス]
        c << header

        users.each do |user|
          values = [user.name, user.email]
          c << values
        end
      end
      send_data(csv, filename: 'share.csv', type: 'application/csv')
    end

    def message_and_redirect(message)
      flash[:danger] = message
      redirect_to edit_group_url(@group)
    end
end
