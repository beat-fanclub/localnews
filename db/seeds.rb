# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

logger = Rails.logger

def point
  "POINT(#{rand 2..6.0} #{rand 50..51.0})"
end

user_count = 20
logger.info "Creating users..."
user_count.times do |i|
  User.create!({
    name: "User #{i}",
    email: "user#{i}@example.com",
    password: "123456"
  })
end
users = User.create!([
  { name: "Alice", email: "alice@example.com", password: "123456" },
  { name: "Bob", email: "bob@example.com", password: "123456" }
])

post_count = user_count * 5
logger.info "Creating posts..."
post_count.times do |i|
  created_at = rand(post_count * 5).minutes.ago
  Post.create!([
    {
      title: "My post ##{i}",
      body: "#{i} is a supreme number. Here's why.",
      location: point,
      user_id: User.all.offset(rand(user_count)).first.id,
      created_at: created_at,
      updated_at: created_at
    }
  ])
end

vote_count = (post_count * 20)
logger.info "Creating votes..."
vote_count.times do |i|
  User.all.offset(rand(user_count)).first.vote(
    Post.all.offset(rand(post_count)).first,
    rand(0..3).zero? ? :down : :up
  )
end

