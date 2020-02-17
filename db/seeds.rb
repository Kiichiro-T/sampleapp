
# Admin User
User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  definitive_registration: true,
  confirmed_at: Time.now
)


# 幹事User
User.create!(
  name: "Executive 1",
  email: "executive1@example.com",
  password: "password",
  password_confirmation: "password",
  definitive_registration: true,
  confirmed_at: Time.now
)


5.times do |i|
  User.create!(
    name: "General #{i+1}",
    email: "General#{i+1}@example.com",
    password: "password",
    password_confirmation: "password",
    definitive_registration: true,
    confirmed_at: Time.now
  )
end

User.create!(
  name: "definitive_test_user",
  email: "definitive_test@example.com",
  password: "password",
  password_confirmation: "password",
  definitive_registration: false,
  confirmed_at: Time.now
)

# Group
2.times do |i|
  Group.create!(
    name: "Group #{i+1}",
    email: "executive1@example.com",
    group_number: "group_test_#{i+1}",
  )
end

# GroupUser
# Executive 1
2.times do |i|
  GroupUser.create!(
    group_id: i+1,
    user_id: 2,
    role: 90,
  )
end

# General 1 ~ 5
5.times do |i|
  GroupUser.create!(
    group_id: 1,
    user_id: i+3,
    role: 10,
  )
end

# Executive 1 & Group 1のEvent
5.times do |i|
  Event.create!(
    name: "合宿#{i+1}",
    user_id: 2,
    group_id: 1,
    start_date: Date.today.next_year(3).to_datetime,
    end_date: Date.today.next_year(3).to_datetime,
    amount: (i+1)*1000,
    description: "これは合宿#{i+1}用のテスト説明です。",
    pay_deadline: Date.today.next_year(3).to_datetime
  )
end

# Events 1~5のTransaction
5.times do |n|
  # Executive 1
  Event::Transaction.create!(
    deadline: Date.today.next_year(3).to_datetime,
    debt: (n+1)*1000,
    payment: (n+1)*1000,
    creditor_id: 2,
    debtor_id: 2,
    group_id: 1,
    event_id: n+1
  )
  # 支払っている人
  2.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n+1)*1000,
      payment: 500 * (n+1) * (i+1),
      creditor_id: 2,
      debtor_id: i+3,
      group_id: 1,
      event_id: n+1
    )
  end

  3.times do |i|
    Event::Transaction.create!(
      deadline: Date.today.next_year(3).to_datetime,
      debt: (n+1)*1000,
      payment: 0,
      creditor_id: 2,
      debtor_id: i+5,
      group_id: 1,
      event_id: n+1
    )
  end
end