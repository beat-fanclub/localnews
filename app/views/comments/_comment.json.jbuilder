json.extract! comment, :id, :post_id, :body, :edited, :parent_id, :created_at, :updated_at
json.url comment_url(comment, format: :json)
json.children comment.children, partial: "comments/comment", as: :comment
json.user do
  json.partial! "users/user", user: comment.user
end
json.partial! "votes/voteable", voteable: comment
