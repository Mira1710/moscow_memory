class TabSessionsController < ApplicationController
  def destroy
    case params[:role]
    when "admin"
      session.delete(:admin_user_id)
      session.delete(:admin_authenticated_at)
    when "user"
      session.delete(:user_id)
      session.delete(:user_session_version)
    else
      return head :bad_request
    end
    head :no_content
  end
end
