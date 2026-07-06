class TagsController < ApplicationController
  before_action :require_login!, only: [ :create ]
  before_action :set_tag, only: [ :show ]

  def index
    @page_title = "タグ一覧"
    @tags = Tag.visible_to(current_user).order(:name)
  end

  def show
    @page_title = "##{@tag.name}"
    scope = @tag.posts.includes(:tags, :user, :favorites).order(created_at: :desc)
    @posts, @total_pages, @current_page = paginate(scope)
    render "posts/index"
  end

  def create
    @tag = current_user.tags.build(tag_params)

    if @tag.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to posts_path, notice: "タグを作成しました" }
        format.json { render json: @tag, status: :created, location: @tag }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_content }
        format.html { redirect_to posts_path, alert: @tag.errors.full_messages.to_sentence }
        format.json { render json: @tag.errors, status: :unprocessable_content }
      end
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
