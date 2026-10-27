class PlacesController < ApplicationController
  layout :places_layout
  before_action :require_admin, except: %i[index show]
  before_action :set_place, only: %i[ show edit update destroy ]

  def index
    @places = Place.includes(:historical_states).order(:name)
    render "places/index"
  end

  def show
    render "places/show"
  end

  def new
    return redirect_to new_admin_place_path unless controller_path.start_with?("admin/")
    @place = Place.new
    @place.historical_states.build
    render "places/new"
  end

  def edit
    return redirect_to edit_admin_place_path(@place) unless controller_path.start_with?("admin/")
    render "places/edit"
  end

  def create
    @place = Place.new(place_params)

    respond_to do |format|
      if @place.save
        format.html { redirect_to admin_place_path(@place), notice: "Объект и статья сохранены." }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render "places/new", status: :unprocessable_content }
        format.json { render json: @place.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to admin_place_path(@place), notice: "Изменения статьи сохранены.", status: :see_other }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render "places/edit", status: :unprocessable_content }
        format.json { render json: @place.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @place.destroy!

    respond_to do |format|
      format.html { redirect_to admin_places_path, notice: "Объект удалён.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def places_layout
      controller_path.start_with?("admin/") || !%w[index show].include?(action_name) ? "admin" : "application"
    end

    def set_place
      @place = Place.find(params.expect(:id))
    end

    def place_params
      params.require(:place).permit(
        :name, :description, :address, :latitude, :longitude, :year_from, :year_to,
        :image, :image_cache, :remove_image, :category, :founded, :architectural_style,
        :architect, :sources, :article_topic, :photo_images_cache, :map_images_cache, :object_images_cache,
        new_photo_images: [], new_map_images: [], new_object_images: [],
        remove_photo_images: [], remove_map_images: [], remove_object_images: [],
        historical_states_attributes: [ :id, :title, :description, :year_from, :year_to,
          :_destroy, :images_cache, :show_preserved, :show_lost, :preserved_text, :lost_text,
          :preserved_images_cache, :lost_images_cache,
          { new_images: [], remove_images: [], new_preserved_images: [], remove_preserved_images: [], new_lost_images: [], remove_lost_images: [] } ]
      )
    end
end
