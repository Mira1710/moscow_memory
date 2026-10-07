class HomeController < ApplicationController
  def index
    @places = Place.limit(3)
  end
end