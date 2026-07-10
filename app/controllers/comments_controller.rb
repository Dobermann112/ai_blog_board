class CommentsController < ApplicationController
  before_action :require_login!
  before_action :set_post
  before_action :set_comment, only: [ :edit, :update, :destroy ]
  before_action -> { authorize_owner!(@comment) }, only: [ :edit, :update, :destroy ]

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      respond_to do |format|
        format.html { redirect_to post_path(@post, anchor: "comments"), notice: "コメントを投稿しました" }
        format.json { render json: @comment, status: :created }
      end
    else
      respond_to do |format|
        format.html { render "posts/show", status: :unprocessable_content }
        format.json { render json: @comment.errors, status: :unprocessable_content }
      end
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post, anchor: "comments"), notice: "コメントを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to post_path(@post, anchor: "comments"), notice: "コメントを削除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
