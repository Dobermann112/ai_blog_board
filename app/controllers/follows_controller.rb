class FollowsController < ApplicationController
  before_action :require_login!
  before_action :set_user, only: [ :create, :destroy ]

  def index
    @page_title = "フォロー一覧"
    scope = current_user.following.order("follows.created_at DESC")
    @users, @total_pages, @current_page = paginate(scope)
  end

  def create
    if @user == current_user
      redirect_back fallback_location: user_path(@user), alert: "自分自身をフォローすることはできません"
      return
    end

    current_user.follows.find_or_create_by!(followed: @user)

    respond_to do |format|
      format.html { redirect_back fallback_location: user_path(@user), notice: "フォローしました" }
      format.json { head :created }
    end
  end

  def destroy
    current_user.follows.find_by(followed: @user)&.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: user_path(@user), notice: "フォローを解除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
