class PostsController < ApplicationController

  include Pagy::Backend
  include Voteable

  resource_description do
    short "Location-tagged articles"
    param :id, String
  end

  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy, :vote]
  load_and_authorize_resource :post

  has_scope :search, as: :q

  # GET /posts
  # GET /posts.json
  api :GET, '/posts', 'List posts'
  def index
    if params[:map_bounds].present?
      north_east, south_west = JSON.parse(params[:map_bounds]).map do |point|
        { lat: point["lat"], lon: point["lng"] }
      end
      @posts = @posts.within(north_east, south_west) if north_east && south_west
      @bounds = [ north_east, south_west ]
    end
    @posts = apply_scopes(@posts)
    @pagy, @posts = pagy(@posts)
    @filter_params = params.permit(:q, :map_bounds, :page).to_h
    @metadata = pagy_metadata(@pagy) if request.format.json?
  end

  # GET /posts/1
  # GET /posts/1.json
  api :GET, '/posts/:id', 'Show a post'
  def show
    @comment = Comment.new(post: @post)
    @comments = @post.comments.order(created_at: :desc)
  end

  # GET /posts/new
  api :GET, '/posts/new'
  def new
  end

  # GET /posts/1/edit
  api :GET, '/posts/:id/edit'
  def edit
  end

  # POST /posts
  # POST /posts.json
  api :POST, '/posts', 'Create a post'
  def create
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
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
