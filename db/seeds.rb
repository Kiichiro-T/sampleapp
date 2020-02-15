
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
  name: "Leader 1",
  email: "leader1@example.com",
  password: "password",
  password_confirmation: "password",
  definitive_registration: true,
  confirmed_at: Time.now
)

5.times do |i|
  User.create!(
    name: "Test User #{i}",
    email: "test#{i}@example.com",
    password: "password",
    password_confirmation: "password",
    definitive_registration: true,
    confirmed_at: Time.now
  )
end

# Group

Group.create!(
  name: "Group 1",
  email: "test1@example.com",
  group_number: "grouptest1",
  leader_id: 2
)