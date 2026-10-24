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
    get articles_path
    assert_select ".article-index a[href='#{place_path(places(:one))}']", 1
  end
end
