class Event::Transaction < Transaction
  def self.divide_transaction_in_two(event)
    completed_transactions = []   # 支払い済み
    uncompleted_transactions = [] # 未払い
    Event::Transaction.where(event_id: event.id).each do |transaction|
      if transaction.debt == transaction.payment
        completed_transactions << transaction
      else
        uncompleted_transactions << transaction
      end
    end
    { completed: completed_transactions, uncompleted: completed_transactions }
  end

  def self.new_transaction_when_create_new_event(member, user, group, event)
    Event::Transaction.create!(
      deadline: event.pay_deadline,
      debt: event.amount,
      payment: 0,
      creditor_id: user.id,
      debtor_id: member.id,
      group_id: group.id,
      event_id: event.id,
      url_token: SecureRandom.hex(10)
    )
  end

  def update_transaction_when_update_event(member, user, event)
    self.update_attributes(
      deadline: event.pay_deadline,
      debt: event.amount,
      creditor_id: user.id,
      debtor_id: member.id,
      url_token: SecureRandom.hex(10)
    )
  end
end
