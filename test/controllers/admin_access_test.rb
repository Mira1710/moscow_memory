require "test_helper"

class AdminAccessTest < ActionDispatch::IntegrationTest
  test "anonymous visitors can read but cannot write through either route" do
    place = places(:one)
    get place_path(place)
    assert_response :success
    assert_select "a[href='#{edit_admin_place_path(place)}']", 0
    get admin_places_path
    assert_redirected_to admin_login_path
    [ places_path, admin_places_path ].each do |path|
      assert_no_difference("Place.count") { post path, params: { place: { name: "Запрещено" } } }
      assert_redirected_to admin_login_path
    end
    [ place_path(place), admin_place_path(place) ].each do |path|
      patch path, params: { place: { name: "Запрещено" } }
      assert_redirected_to admin_login_path
      assert_not_equal "Запрещено", place.reload.name
      assert_no_difference("Place.count") { delete path }
    end
  end

  test "login logout and session expiry protect the admin" do
    post admin_session_path, params: { email: "author@example.test", password: "wrong" }
    assert_response :unprocessable_content
    post admin_session_path, params: { email: "AUTHOR@example.test", password: "test-author-password-123" }
    assert_redirected_to admin_places_path
    get admin_places_path
    assert_response :success
    travel 13.hours do
      get admin_places_path
      assert_redirected_to admin_login_path
    end
    post admin_session_path, params: { email: "author@example.test", password: "test-author-password-123" }
    delete admin_logout_path
    assert_redirected_to admin_login_path
    get admin_places_path
    assert_redirected_to admin_login_path
  end

  test "first owner setup is local only and cannot be repeated" do
    AdminUser.delete_all
    get admin_setup_path, env: { "REMOTE_ADDR" => "203.0.113.7" }
    assert_response :not_found
    get admin_setup_path, env: { "REMOTE_ADDR" => "127.0.0.1" }
    assert_response :success
    post admin_setup_path, params: { admin_user: { email: "owner@example.test", password: "my-new-author-password", password_confirmation: "my-new-author-password" } }, env: { "REMOTE_ADDR" => "127.0.0.1" }
    assert_redirected_to admin_places_path
    assert_equal 1, AdminUser.count
    assert_not_equal "my-new-author-password", AdminUser.first.password_digest
    assert_no_difference("AdminUser.count") do
      post admin_setup_path, params: { admin_user: { email: "other@example.test", password: "my-new-author-password", password_confirmation: "my-new-author-password" } }, env: { "REMOTE_ADDR" => "127.0.0.1" }
    end
    assert_response :not_found
  end

  test "each period section can be hidden and restored without losing content or photos" do
    post admin_session_path, params: { email: "author@example.test", password: "test-author-password-123" }
    place = places(:one)
    state = place.historical_states.first
    photo = -> { fixture_file_upload("editor.png", "image/png") }
    patch admin_place_path(place), params: { place: { historical_states_attributes: { "0" => {
      id: state.id, show_preserved: "1", show_lost: "1", preserved_text: "Сохранился слой", lost_text: "Утрачены постройки",
      new_preserved_images: [ photo.call ], new_lost_images: [ photo.call ]
    } } } }
    assert_redirected_to admin_place_path(place)
    assert_equal 1, state.reload.preserved_images.size
    assert_equal 1, state.lost_images.size
    get root_path
    assert_select "template[data-place-id='#{place.id}'] [data-period-section=preserved] img", 1
    assert_select "template[data-place-id='#{place.id}'] [data-period-section=lost] img", 1
    patch admin_place_path(place), params: { place: { historical_states_attributes: { "0" => { id: state.id, show_preserved: "0" } } } }
    assert_equal "Сохранился слой", state.reload.preserved_text
    assert_equal 1, state.preserved_images.size
    get root_path
    assert_select "template[data-place-id='#{place.id}'] [data-period-section=preserved]", 0
    assert_select "template[data-place-id='#{place.id}'] [data-period-section=lost]", 1
    patch admin_place_path(place), params: { place: { historical_states_attributes: { "0" => { id: state.id, show_preserved: "1" } } } }
    get root_path
    assert_select "template[data-place-id='#{place.id}'] [data-period-section=preserved] img", 1
  end
  test "admin navigation stays internal and public pages never show author controls" do
    post admin_session_path, params: { email: "author@example.test", password: "test-author-password-123" }
    [ admin_places_path, admin_map_path, admin_walking_routes_path, admin_forum_path, admin_about_path, admin_profile_path ].each do |path|
      get path
      assert_response :success
      assert_select ".admin-shell", 1
      assert_select ".admin-sidebar nav a", 6
      css_select(".admin-sidebar a").each { |link| assert link["href"].start_with?("/admin") }
      assert_select ".admin-topbar form[action='#{admin_logout_path}']", 1
      css_select(".admin-content a").each { |link| assert link["href"].start_with?("/admin"), "Admin link escapes to #{link['href']}" }
    end
    [ root_path, articles_path, places_path, place_path(places(:one)) ].each do |path|
      get path
      assert_response :success
      assert_select "a[href^='/admin']", 0
      assert_select "form[action^='/admin']", 0
    end
    delete admin_logout_path
    assert_redirected_to admin_login_path
    get admin_login_path
    assert_response :success
    assert_select "a[href='/']", 0
  end
end
