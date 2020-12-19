json.extract! voteable, :score
json.voted current_user.voted?(voteable)&.direction if current_user
