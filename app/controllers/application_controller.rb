class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  #before_action :configure_permitted_parameters, if: :devise_controller?

  private
    def confirm_definitive_registration
      unless current_user.definitive_registration
        flash[:danger] = "アカウントは一括登録後の状態ですので、パスワードまたはメールアドレスを変更するようにしてください。"
        redirect_to edit_user_registration_url
      end
    end
end
