module Admin
  class PlacesController < ::PlacesController
    layout "admin"
    before_action :require_admin
  end
end
