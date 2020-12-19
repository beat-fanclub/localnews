json.extract! post, :id, :title, :content, :created_at, :score
json.url post_url(post, format: :json)
json.user post.user, partial: "users/user", as: :user
json.comments post.comments.toplevel, partial: "comments/comment", as: :comment
json.partial! "votes/voteable", voteable: post
json.body post.body&.body&.to_rendered_html_with_layout
