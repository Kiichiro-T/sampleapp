# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  # before_action :configure_permitted_parameters, if: :devise_controller?

  include GroupsHelper

  private

    # 後で実装
    def only_executives_can_access
      GroupUser.where(user_id: current_user.id).each do |relationship|
        if relationship.role == GroupUser.roles[:executive]
          @exe_group = Group.find(relationship.group_id)
        end
      end

      if @exe_group && @exe_group.id == params[:exe_group_id]
      else
        flash[:danger] = '不正な操作です。'
        redirect_to root_url
      end
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      return if Group.my_groups(current_user).include?(@group)

      flash[:danger] = '不正な操作です。'
      redirect_to root_url
    end

    # 現在のユーザーが幹事であるグループをセットする
    def set_group_for_current_executive
      @current_executive_group = Group.my_own_group(current_user)
    end

    def confirm_definitive_registration
      return if current_user.definitive_registration

      flash[:danger] = 'アカウントは一括登録後の状態ですので、パスワードまたはメールアドレスを変更するようにしてください。'
      redirect_to edit_user_registration_url
    end

    # ログイン後のリダイレクト先
    def after_sign_in_path_for(resource_or_scope)
      root_path
    end

    # ログアウト後のリダイレクト先
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end
end
