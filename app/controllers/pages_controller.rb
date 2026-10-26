class PagesController < ApplicationController
  layout "section"

  def routes
    @route_sections = YAML.safe_load_file(Rails.root.join("config/walking_routes.yml")).fetch("sections")
  end

  def articles
    @article_sections = YAML.safe_load_file(Rails.root.join("config/article_catalogue.yml")).fetch("sections")
    @selected_topic = params[:topic] if Place::ARTICLE_TOPICS.key?(params[:topic])
    @places = Place.order(:name)
    @places = @places.where(article_topic: @selected_topic) if @selected_topic
  end

  def forum
  end

  def about
  end

  def profile
  end
end
