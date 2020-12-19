json.extract! voteable, :votes_sum
json.voted current_user.voted?(voteable)&.direction if current_user
