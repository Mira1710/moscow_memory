class HomeController < ApplicationController
  def index
    @places = Place.includes(:historical_states).order(:id)
  end
end
