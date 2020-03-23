class UpdateEventJob < ApplicationJob
  queue_as :default

  # update transaction to group members when update a event.
  def perform(members, current_user, group, event)
    members.each do |member|
      transaction = Transaction.find_by(group_id: group.id, event_id: event.id, debtor_id: member.id)
      transaction.update_transaction_when_update_event(member, current_user, event)
      NotificationMailer.send_when_update_event(member, current_user, group, event).deliver_later(wait: 1.minute)
    end
  end
end
