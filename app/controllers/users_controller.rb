class UsersController < ApplicationController
  before_action :set_user, only: [ :show ]

  def show
    @page_title = "#{@user.email}さんの投稿"
    scope = @user.posts.published.includes(:tags, :user, :favorites).order(created_at: :desc)
    @posts, @total_pages, @current_page = paginate(scope)
    render "posts/index"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
