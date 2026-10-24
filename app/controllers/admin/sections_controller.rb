module Admin
  class SectionsController < ApplicationController
    layout "admin"
    before_action :require_admin

    def map
      @places = Place.order(:name)
    end

    def routes
    end

    def forum
    end

    def about
    end

    def profile
    end
  end
end
