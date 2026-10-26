class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_admin, :admin_signed_in?, :admin_interface?

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)
    user = User.find_by(id: session[:user_id]) if session[:user_id]
    @current_user = user if user && user.session_version == session[:user_session_version]
  end

  def require_user
    redirect_to user_login_path, alert: "Войдите в свой профиль.", status: :see_other unless current_user
  end


  def current_admin
    return @current_admin if defined?(@current_admin)
    authenticated_at = session[:admin_authenticated_at].to_i
    @current_admin = if authenticated_at > 12.hours.ago.to_i
      AdminUser.find_by(id: session[:admin_user_id])
    end
  end

  def admin_signed_in?
    current_admin.present?
  end

  def admin_interface?
    controller_path.start_with?("admin/") && admin_signed_in?
  end

  def require_admin
    return if admin_signed_in?
    redirect_to admin_login_path, alert: "Войдите в админку, чтобы редактировать статьи.", status: :see_other
  end
end
