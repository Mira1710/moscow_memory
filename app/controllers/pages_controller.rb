class PagesController < ApplicationController
  layout "section"

  def routes
    @route_sections = YAML.safe_load_file(Rails.root.join("config/walking_routes.yml")).fetch("sections")
  end

  def articles
    @places = Place.order(:name)
  end

  def forum
  end

  def about
  end

  def profile
  end
end
