class FavoritesController < ApplicationController
  before_action :require_login!
  before_action :set_post, only: [ :create, :destroy ]

  def index
    @page_title = "お気に入り一覧"
    scope = current_user.favorite_posts.published.includes(:tags, :user, :favorites).order("favorites.created_at DESC")
    @posts, @total_pages, @current_page = paginate(scope)
    render "posts/index"
  end

  def create
    current_user.favorites.find_or_create_by!(post: @post)

    respond_to do |format|
      format.html { redirect_back fallback_location: post_path(@post), notice: "お気に入りに追加しました" }
      format.json { head :created }
    end
  end

  def destroy
    current_user.favorites.find_by(post: @post)&.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: post_path(@post), notice: "お気に入りを解除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
