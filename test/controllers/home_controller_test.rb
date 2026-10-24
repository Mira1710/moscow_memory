require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "map renders database places and their history with escaped content" do
    place = places(:one)
    place.update!(name: "<script>alert(1)</script>")
    get root_url
    assert_response :success
    assert_select '[data-controller="memory-map"]'
    assert_select 'template[data-place-id="' + place.id.to_s + '"]', 1
    assert_includes response.body, "&lt;script&gt;alert(1)&lt;/script&gt;"
    assert_select 'template script', 0
    assert_select '.historical-state', 2
    assert_select '#memory-article[hidden]', 1
    assert_select 'script', { text: /L.map/ , count: 0 }
  end
end
