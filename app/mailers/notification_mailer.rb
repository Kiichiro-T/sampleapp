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

  def send_when_make_new_event(user, current_user, group, event)
    @user = user
    @current_user = current_user
    @group = group
    @event = event
    mail(
      subject: "仮登録のお知らせ",
      to: @user.email
    ) do |format|
      format.text
    end
  end

end
