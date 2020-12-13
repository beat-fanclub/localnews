# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = User.create!([
  { name: "Alice", email: "alice@example.com", password: "123456" },
  { name: "Bob", email: "bob@example.com", password: "123456" }
])

Post.create!([
  { title: "My post", body: "My best content!", location: "POINT(50 50)",
    user_id: users.first.id },
  { title: "My question", body: "My best content!", location: "POINT(0 50)",
    user_id: users.second.id },
  { title: "My blog", body: "My best content!", location: "POINT(50 0)",
    user_id: users.first.id },
])

