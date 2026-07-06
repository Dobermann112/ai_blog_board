class TagsController < ApplicationController
  before_action :require_login!, only: [ :new, :create ]
  before_action :set_tag, only: [ :show ]

  def index
    @page_title = "タグ一覧"
    @tags = Tag.order(:name)
  end

  def show
    @page_title = "##{@tag.name}"
    @posts = @tag.posts.includes(:tags, :user, :favorites).order(created_at: :desc)
    render "posts/index"
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      respond_to do |format|
        format.html { redirect_to tags_path, notice: "タグを作成しました" }
        format.json { render json: @tag, status: :created, location: @tag }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
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
