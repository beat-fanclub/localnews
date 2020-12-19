class UsersController < ApplicationController
  load_and_authorize_resource :user

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  api :GET, '/users/:id', 'Show an user'
  def show
    @posts = @user.posts.limit(100)
    @comments = @user.comments.limit(100)
  end
end
