class SavedRoutesController < ApplicationController
  before_action :require_user

  def create
    route_key = params[:route_key].to_s
    return head :not_found unless SavedRoute.catalogue.key?(route_key)
    current_user.saved_routes.find_or_create_by!(route_key: route_key)
    redirect_to profile_path(anchor: "profile-favorites"), notice: "Маршрут добавлен в избранное.", status: :see_other
  end

  def destroy
    current_user.saved_routes.find(params[:id]).destroy!
    redirect_to profile_path(anchor: "profile-favorites"), status: :see_other
  end
end
