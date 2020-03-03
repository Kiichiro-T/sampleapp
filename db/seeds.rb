# frozen_string_literal: true

# Admin User
User.create!(
  name: 'Admin',
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: true,
  confirmed_at: Time.now
)

# 幹事User1
User.create!(
  name: 'Executive 1',
  email: 'executive1@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: true,
  confirmed_at: Time.now
)

# 幹事User2
User.create!(
  name: 'Executive 2',
  email: 'executive2@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: true,
  confirmed_at: Time.now
)

10.times do |i|
  User.create!(
    name: "General #{i + 1}",
    email: "General#{i + 1}@example.com",
    password: 'password',
    password_confirmation: 'password',
    definitive_registration: true,
    confirmed_at: Time.now
  )
end

User.create!(
  name: 'definitive_test_user',
  email: 'definitive_test@example.com',
  password: 'password',
  password_confirmation: 'password',
  definitive_registration: false,
  confirmed_at: Time.now
)

# Group
2.times do |i|
  Group.create!(
    name: "Group #{i + 1}",
    email: "executive#{i + 1}@example.com",
    group_number: "group_test_#{i + 1}"
  )
end

# GroupUser
# Executive 1(Group1) & 2(Group2)
2.times do |i|
  GroupUser.create!(
    group_id: i + 1,
    user_id: i + 2,
    role: 90
  )
end

# General 1 ~ 5
5.times do |i|
  GroupUser.create!(
    group_id: 1,
    user_id: i + 4,
    role: 10
  )
end
# General 6 ~ 10
5.times do |i|
  GroupUser.create!(
    group_id: 2,
    user_id: i + 9,
    role: 10
  )
end

# Executive 1 & Group 1のEvent
5.times do |i|
  Event.create!(
    name: "合宿#{i + 1}",
    user_id: 2,
    group_id: 1,
    start_date: Date.today.next_year(3).to_datetime,
    end_date: Date.today.next_year(3).to_datetime,
    amount: (i + 1) * 1000,
    description: "これは合宿#{i + 1}用のテスト説明です。",
    pay_deadline: Date.today.next_year(3).to_datetime
  )
end

# Executive 2 & Group 2のEvent
5.times do |i|
  Event.create!(
    name: "旅行#{i + 1}",
    user_id: 3,
    group_id: 2,
    start_date: Date.today.next_year(3).to_datetime,
    end_date: Date.today.next_year(3).to_datetime,
    amount: (i + 1) * 1000,
    description: "これは旅行#{i + 1}用のテスト説明です。",
    pay_deadline: Date.today.next_year(3).to_datetime
  )
end

# Group 1 & Events 1~5のTransaction
5.times do |n|
  # Executive 1
  Event::Transaction.create!(
    deadline: Date.today.next_year(3).to_datetime,
    debt: (n + 1) * 1000,
    payment: (n + 1) * 1000,
    creditor_id: 2,
    debtor_id: 2,
    group_id: 1,
    event_id: n + 1,
    url_token: SecureRandom.hex(10)
  )
  # 支払っている人
  2.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n + 1) * 1000,
      payment: 500 * (n + 1) * (i + 1),
      creditor_id: 2,
      debtor_id: i + 4,
      group_id: 1,
      event_id: n + 1,
      url_token: SecureRandom.hex(10)
    )
  end

  3.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n + 1) * 1000,
      payment: 0,
      creditor_id: 2,
      debtor_id: i + 6,
      group_id: 1,
      event_id: n + 1,
      url_token: SecureRandom.hex(10)
    )
  end
end

# Group 2 & Events 1~5のTransaction
5.times do |n|
  # Executive 2
  Event::Transaction.create!(
    deadline: Date.today.next_year(3).to_datetime,
    debt: (n + 1) * 1000,
    payment: (n + 1) * 1000,
    creditor_id: 3,
    debtor_id: 3,
    group_id: 2,
    event_id: n + 6,
    url_token: SecureRandom.hex(10)
  )
  # 支払っている人
  2.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n + 1) * 1000,
      payment: 500 * (n + 1) * (i + 1),
      creditor_id: 3,
      debtor_id: i + 9,
      group_id: 2,
      event_id: n + 6,
      url_token: SecureRandom.hex(10)
    )
  end

  3.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n + 1) * 1000,
      payment: 0,
      creditor_id: 3,
      debtor_id: i + 11,
      group_id: 2,
      event_id: n + 6,
      url_token: SecureRandom.hex(10)
    )
  end
end
