class PagesController < ApplicationController
  layout "section"

  def routes
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
