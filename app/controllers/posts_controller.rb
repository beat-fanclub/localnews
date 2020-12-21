class PostsController < ApplicationController

  include Pagy::Backend
  include Voteable

  def_param_group :post do
    #param :post, Hash, action_aware: true do
      param :id, String
      param :title, String
      param :body, String
      param :user_id, String
      param :location, String
      param :location_desc, String
      param :comments, array_of: :comment
    #end
  end

  resource_description do
    short "Location-tagged articles"
  end

  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy, :vote]
  load_and_authorize_resource :post

  has_scope :search, as: :q

  # GET /posts
  # GET /posts.json
  api :GET, '/posts', 'List posts'
  param :map_bounds, String
  param :q, String, "Search query"
  def index
    @center = "locate"

    # Save posts before querying by location
    global_posts = @posts
    if params[:map_bounds].present?
      north_east, south_west = JSON.parse(params[:map_bounds]).map do |point|
        { lat: point["lat"], lon: point["lng"] }
      end
      @posts = @posts.within(north_east, south_west) if north_east && south_west
      @bounds = [ north_east, south_west ]
      @center = "bounds"
    end
    @posts = apply_scopes(@posts)

    @pagy, @posts = pagy(@posts)
    @filter_params = params.permit(:q, :map_bounds, :page).to_h
    @metadata = pagy_metadata(@pagy, true)
  end

  # GET /posts/1
  # GET /posts/1.json
  api :GET, '/posts/:id', 'Show a post'
  returns :post
  def show
    @comment = Comment.new(post: @post)
    @comments = @post.comments.order(created_at: :desc)
  end

  # GET /posts/new
  def new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  api :POST, '/posts', 'Create a post'
  param_group :post
  def create
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { broadcast_errors(@post, post_params); render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  api :PATCH, '/posts/:id', 'Update a post'
  api :PUT, '/posts/:id', 'Update a post'
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.js { broadcast_errors(@post, post_params) }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  api :DELETE, '/posts/:id', 'Destroy a post'
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def voteable
    @post
  end

  add_voteable_action "posts"

  private
    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :location, :location_desc, :source)
    end
end
