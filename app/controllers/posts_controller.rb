class PostsController < ApplicationController
  before_action :require_login!, except: [ :index, :show ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action -> { authorize_owner!(@post) }, only: [ :edit, :update, :destroy ]
  before_action :set_tags, only: [ :new, :create, :edit, :update ]

  def index
    @page_title = "記事一覧"
    scope = Post.includes(:tags, :user, :favorites).order(created_at: :desc)
    @posts, @total_pages, @current_page = paginate(scope)
  end

  def mypage
    @page_title = "マイページ"
    @page_subtitle = "自分の投稿"
    scope = current_user.posts.includes(:tags, :user, :favorites).order(created_at: :desc)
    @posts, @total_pages, @current_page = paginate(scope)
    render :index
  end

  def show
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      respond_to do |format|
        format.html { redirect_to @post, notice: "記事を投稿しました" }
        format.json { render :show, status: :created, location: @post }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @post.errors, status: :unprocessable_content }
      end
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to @post, notice: "記事を更新しました" }
        format.json { render :show, status: :ok, location: @post }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @post.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "記事を削除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def set_tags
    @tags = Tag.visible_to(current_user).order(:name)
  end

  def post_params
    params.require(:post).permit(:title, :body, tag_ids: [])
  end
end
