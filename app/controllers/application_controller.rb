# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  # before_action :configure_permitted_parameters, if: :devise_controller?

  include GroupsHelper

  private

    # 幹事のみアクセス可能
    def only_executives_can_access
      return unless GroupUser.general_relationship(group: @group, user: current_user)

      flash[:danger] = '幹事しかアクセスできません'
      redirect_to root_url
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      return if Group.is_my_group?(user: current_user, group: @group)

      flash[:danger] = '所属していないグループにはアクセスできません'
      redirect_to root_url
    end

    # 現在のユーザーが幹事であるグループをセットする
    # def set_group_for_current_executive
    #   @current_executive_group = Group.my_own_group(current_user)
    # end

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
