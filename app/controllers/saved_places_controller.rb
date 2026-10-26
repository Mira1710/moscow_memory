class SavedPlacesController < ApplicationController
  before_action :require_user

  def create
    current_user.saved_places.find_or_create_by!(place: Place.find(params[:place_id]))
    redirect_to profile_path(anchor: "profile-favorites"), notice: "Статья добавлена в избранное.", status: :see_other
  end

  def destroy
    current_user.saved_places.find(params[:id]).destroy!
    redirect_to profile_path(anchor: "profile-favorites"), status: :see_other
  end
end
