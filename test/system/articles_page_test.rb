require "application_system_test_case"

class ArticlesPageTest < ApplicationSystemTestCase
  teardown { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }

  test "catalogue highlights cards and opens actual articles by theme" do
    place = places(:one)
    place.update!(article_topic: "zamoskvorechye", name: "Статья из базы")
    visit articles_path
    assert_selector ".article-topic-section", count: 3
    assert_selector ".article-topic-card", count: 9
    page.save_screenshot(Rails.root.join("tmp/screenshots/articles-desktop.png"))
    card = first(".article-topic-card")
    if page.evaluate_script('matchMedia("(hover: hover)").matches')
      card.hover
    else
      page.execute_script("arguments[0].focus()", card)
    end
    card.synchronize do
      color = card.find("h3").style("color")["color"].scan(/[\d.]+/).first(3).map(&:to_i)
      border = card.style("border-top-color")["border-top-color"].scan(/[\d.]+/).first(3).map(&:to_i)
      raise Capybara::ExpectationNotMet unless color == [ 183, 17, 22 ] && border == color
    end
    page.save_screenshot(Rails.root.join("tmp/screenshots/articles-hover.png"))
    card.click
    assert_selector "#article-results[open]"
    within ".article-index" do
      click_link "Статья из базы"
    end
    assert_current_path place_path(place)
  end

  test "mobile catalogue retains cards navigation and readable widths" do
    [ 320, 390, 768 ].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 844, deviceScaleFactor: 1, mobile: true)
      visit articles_path
      assert_selector ".article-topic-card", count: 9
      assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
      if width < 768
        find("button[aria-label='Открыть меню']").click
        assert_selector "#articles-navigation .menu-link", count: 6
        find("button[aria-label='Закрыть меню']").click
        assert_no_selector ".sidebar", visible: true
      end
      page.save_screenshot(Rails.root.join("tmp/screenshots/articles-#{width}.png"))
    end
  end
end
