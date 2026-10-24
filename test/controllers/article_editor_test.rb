require "test_helper"

class ArticleEditorTest < ActionDispatch::IntegrationTest
  setup do
    post admin_session_path, params: { email: "author@example.test", password: "test-author-password-123" }
  end
  def photo
    fixture_file_upload("editor.png", "image/png")
  end

  test "article and period uploads appear on map and survive subsequent edits" do
    post places_path, params: { place: {
      name: "Место из редактора", description: "Текст статьи <script>alert(1)</script>", address: "Москва",
      latitude: "55.75", longitude: "37.62", category: "public_spaces", founded: "XIX век",
      architectural_style: "Модерн", architect: "Автор", sources: "Архив, фонд 1",
      image: photo, new_photo_images: [photo], new_map_images: [photo], new_object_images: [photo],
      historical_states_attributes: { "0" => { title: "Первый период", description: "История периода", year_from: 1900, year_to: 1950, new_images: [photo] } }
    } }
    place = Place.order(:id).last
    assert_redirected_to admin_place_path(place)
    assert_equal "public_spaces", place.category
    assert_equal 1, place.photo_images.size
    assert_equal 1, place.map_images.size
    assert_equal 1, place.object_images.size
    state = place.historical_states.first
    assert_equal 1, state.images.size
    assert File.file?(place.photo_images.first.path)
    assert File.file?(state.images.first.path)

    get root_path
    assert_response :success
    assert_select "template[data-place-id='#{place.id}'][data-category=public_spaces]", 1
    assert_select "template[data-place-id='#{place.id}'] .article-photo-grid img", 4
    assert_includes response.body, "Архив, фонд 1"
    assert_select "template script", 0

    patch place_path(place), params: { place: { description: "Обновлённый текст", new_photo_images: [photo],
      historical_states_attributes: { "0" => { id: state.id, description: "Обновлённая история", new_images: [photo] } } } }
    assert_redirected_to admin_place_path(place)
    assert_equal 2, place.reload.photo_images.size
    assert_equal 2, state.reload.images.size
    patch place_path(place), params: { place: { name: "Новое название" } }
    assert_equal 2, place.reload.photo_images.size
    assert_equal 2, state.reload.images.size

    patch place_path(place), params: { place: { remove_photo_images: [place.photo_images.first.identifier],
      historical_states_attributes: { "0" => { id: state.id, remove_images: [state.images.first.identifier] } } } }
    assert_equal 1, place.reload.photo_images.size
    assert_equal 1, state.reload.images.size
  end

  test "invalid periods do not partially save the article" do
    place = places(:one)
    name = place.name
    patch place_path(place), params: { place: { name: "Не сохранять", historical_states_attributes: {
      "0" => { title: "Неверные даты", year_from: 2000, year_to: 1900 }
    } } }
    assert_response :unprocessable_content
    assert_equal name, place.reload.name
    assert_not place.historical_states.exists?(title: "Неверные даты")
  end

  test "period can be deleted only from its own article" do
    place = places(:one)
    other = historical_states(:two)
    assert_raises(ActiveRecord::RecordNotFound) { place.update!(historical_states_attributes: [{ id: other.id, _destroy: "1" }]) }
    state = place.historical_states.first
    assert_difference("HistoricalState.count", -1) do
      patch place_path(place), params: { place: { historical_states_attributes: { "0" => { id: state.id, _destroy: "1" } } } }
    end
    assert_redirected_to admin_place_path(place)
  end

  test "blank new period is ignored and invalid category is rejected" do
    place = places(:one)
    assert_no_difference("HistoricalState.count") do
      patch place_path(place), params: { place: { historical_states_attributes: { "0" => { title: "", description: "", year_from: "", year_to: "", show_preserved: "0", show_lost: "0" } } } }
    end
    assert_redirected_to admin_place_path(place)
    patch place_path(place), params: { place: { category: "made_up" } }
    assert_response :unprocessable_content
  end
  test "invalid image type is rejected without creating a place" do
    assert_no_difference("Place.count") do
      post places_path, params: { place: { name: "Ошибка файла", new_photo_images: [fixture_file_upload("not-an-image.txt", "text/plain")] } }
    end
    assert_response :unprocessable_content
  end

  test "cached photos survive validation error and form resubmission" do
    post places_path, params: { place: { name: "", new_photo_images: [photo] } }
    assert_response :unprocessable_content
    cache = css_select('input[name="place[photo_images_cache]"]').first["value"]
    assert cache.present?
    post places_path, params: { place: { name: "Исправленное название", photo_images_cache: cache } }
    place = Place.order(:id).last
    assert_redirected_to admin_place_path(place)
    assert_equal 1, place.photo_images.size
    assert File.file?(place.photo_images.first.path)
  end

end
