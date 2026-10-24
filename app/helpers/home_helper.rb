module HomeHelper
  MAP_CATEGORIES = Place::CATEGORIES

  def map_place_settings(place)
    { "category" => place.category, "founded" => place.founded,
      "style" => place.architectural_style, "architect" => place.architect }
  end

  def map_place_category(place)
    Place::CATEGORIES.key?(place.category) ? place.category : "uncategorized"
  end

  def optional_map_asset(path)
    asset_path(path) if Rails.root.join("app/assets/images", path).file?
  end

  def map_category_asset(key)
    optional_map_asset("markers/#{key}.svg") || (optional_map_asset("markers/estate.svg") if key == "estates")
  end

  def map_marker_asset(place)
    optional_map_asset("markers/places/#{place.id}.svg") ||
      map_category_asset(map_place_category(place)) || optional_map_asset("markers/default.svg")
  end

end
