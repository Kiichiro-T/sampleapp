
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
    role: 0,
  )
end

# General 1 ~ 5
5.times do |i|
  GroupUser.create!(
    group_id: 1,
    user_id: i+3,
    role: 1,
  )
end