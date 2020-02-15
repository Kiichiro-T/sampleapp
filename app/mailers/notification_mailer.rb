class NotificationMailer < ApplicationMailer

  def send_when_batch_registration(user, current_user)
    @user = user
    @current_user = current_user
    mail(
      subject: "仮登録のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

end
