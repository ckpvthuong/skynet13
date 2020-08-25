# frozen_string_literal: true

# Generate a bunch of additional users.
50.times do |n|
  name = Faker::Name.name
  username = "user#{n + 1}"
  email = "#{n + 1}ckpvthuongft@gmail.com"
  password = '111111'

  user = User.create!(
    name: name,
    email: email,
    username: username,
    password: password,
    password_confirmation: password
  )
  user.skip_confirmation!
  user.save!
end

# Create following relationships.
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.posts.create!(content: content) }
end

users = User.order(:created_at).take(7)
6.times do |n|
  sender = users[n]
  recipient = users[n + 1]
  cvs = Conversation.get(sender.id, recipient.id)
  cvs.messages.create!(body: "hello #{recipient.name}, my name is #{sender.name}", user_id: sender.id)

  sender = users[n + 1]
  recipient = users[n]

  cvs.messages.create!(body: "hello #{recipient.name}, my name is #{sender.name}", user_id: sender.id)
end

N = 10;

users = User.order(:created_at).take(N)

(N-1).times do |i|
  source = users[i]
  target = users[i+1]
  target.posts.each do |post|
    post.likes.create(user_id: source.id)
  end
  source = users[i+1]
  target = users[i]
  target.posts.each do |post|
    post.likes.create(user_id: source.id)
  end
end

N = 10;

users = User.order(:created_at).take(N)

(N-1).times do |i|
  source = users[i]
  target = users[i+1]
  target.posts.each do |post|
    post.comments.create(user_id: source.id, content: 'I love your post')
  end
  source = users[i+1]
  target = users[i]
  target.posts.each do |post|
    post.comments.create(user_id: source.id, content: 'I love your post')
  end
end