class NewEventJob < ApplicationJob
  queue_as :default

  # create transaction to group members when create a event.
  def perform(members, current_user, group, event)
    members.each do |member|
      Event::Transaction.new_transaction_when_create_new_event(member, current_user, group, event)
      Answer.new_answer_when_create_new_event(member, event)
      NotificationMailer.send_when_make_new_event(member, current_user, group, event).deliver_later(wait: 1.minute)
    end
  end
end
