class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
  private
    def confirm_definitive_registration
      unless current_user.definitive_registration
        flash[:danger] = "現在仮登録状態です。メールアドレスを変更して本登録してください。"
        redirect_to edit_user_registration_url
      end
    end
end
