class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy, :vote]
  load_and_authorize_resource :post, only: [:new, :create]
  load_and_authorize_resource :comment, through: :post, only: [:new, :create]
  load_and_authorize_resource :comment, except: [:new, :create]

  include Voteable

  # GET /comments/1
  # GET /comments/1.json
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENERATING NEXT TIME
  api :GET, '/comments/:id', 'Show a comment'
  def show
  end

  # GET /comments/new
  api :GET, '/posts/:post_id/comments/new'
  def new
    @parent = Comment.find(params[:parent])
  end

  # GET /comments/1/edit
  api :GET, '/comments/:id/edit'
  def edit
  end

  # POST /comments
  # POST /comments.json
  api :POST, '/posts/:post_id/comments', 'Create a comment'
  def create
    respond_to do |format|
      if @comment.save
        format.html { redirect_to post_path(@post), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  api :PATCH, '/comments/:id', 'Update a comment'
  api :PUT, '/comments/:id', 'Update a comment'
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  api :DELETE, '/comments/:id', 'Destroy a comment'
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to post_path(@post), notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def voteable
    @comment
  end

  add_voteable_action "comments"

  private
    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body)
    end
    def create_params
      params.require(:comment).permit(:body, :parent_id)
    end
end
