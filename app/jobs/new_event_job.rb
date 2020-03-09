class NewEventJob < ApplicationJob
  queue_as :default

  # create transaction to group members when create a event.
  def perform(member, current_user, group, event)
    Event::Transaction.new_transaction_when_create_new_event(member, current_user, group, event)
    Answer.new_answer_when_create_new_event(member, event)
  end
end
