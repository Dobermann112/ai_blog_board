class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_sidebar_tags

  class NotAuthenticatedError < StandardError; end
  class NotAuthorizedError < StandardError; end

  rescue_from NotAuthenticatedError, with: :handle_not_authenticated
  rescue_from NotAuthorizedError, with: :handle_not_authorized

  private

  def set_sidebar_tags
    @sidebar_tags = Tag.order(:name)
  end

  def require_login!
    raise NotAuthenticatedError unless user_signed_in?
  end

  def authorize_owner!(record)
    raise NotAuthorizedError unless record.user == current_user
  end

  def handle_not_authenticated
    respond_to do |format|
      format.html { redirect_to new_user_session_path, alert: "ログインしてください" }
      format.json { head :unauthorized }
    end
  end

  def handle_not_authorized
    respond_to do |format|
      format.html { redirect_to root_path, alert: "この操作を行う権限がありません" }
      format.json { head :forbidden }
    end
  end
end
