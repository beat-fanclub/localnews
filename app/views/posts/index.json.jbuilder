json.posts @posts do |post|
  json.url post_url(post, format: :json)
  json.extract! post, :title, :id, :created_at
  json.partial! "votes/voteable", voteable: post
  json.user do
    json.url user_url(post.user, format: :json)
    json.partial! "users/user", user: post.user
  end
end
json.pagination @metadata
