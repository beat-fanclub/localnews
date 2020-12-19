json.extract! user, :id, :name, :created_at, :updated_at
json.url user_url(user, format: :json)
json.avatar do
  if user.avatar.present?
    json.full full_url_for user.avatar
    json.large full_url_for user.avatar.variant(resize_to_limit: [128, 128])
    json.small full_url_for user.avatar.variant(resize_to_limit: [64, 64])
  else
    json.null!
  end
end

