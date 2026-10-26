require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "each menu section has its own address and active navigation" do
    { walking_routes_path => "routes", articles_path => "articles", forum_path => "forum", about_path => "about", profile_path => "profile" }.each do |path, section|
      get path
      assert_response :success
      assert_select "h1", 1
      assert_select "nav a[aria-current=page][href='#{path}']", 1
      assert_select "nav a", 6
      assert_select '[data-controller="memory-map"]', 0
    end
  end

  test "articles link to actual places" do
    places(:one).update!(article_topic: "maps")
    get articles_path(topic: "maps")
    assert_select ".article-index a[href='#{place_path(places(:one))}']", 1
  end
  test "article themes show only matching saved materials" do
    place = places(:one)
    place.update!(article_topic: "sokolniki")
    get articles_path(topic: "sokolniki")
    assert_response :success
    assert_select ".article-topic-section", 3
    assert_select ".article-topic-card", 9
    assert_select "#article-results", 1
    assert_select ".article-index a[href='#{place_path(place)}']", 1
    assert_select ".article-index a[href='#{place_path(places(:two))}']", 0
    get articles_path(topic: "sounds")
    assert_select ".article-index article", 0
    assert_includes response.body, "Материалы этой темы пока не добавлены"
    get articles_path(topic: "not-a-topic")
    assert_select "#article-results", 0
  end
end
