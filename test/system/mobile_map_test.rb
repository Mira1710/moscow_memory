require "application_system_test_case"

class MobileMapTest < ApplicationSystemTestCase
  teardown { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }

  test "phone map menu timeline and full width article work without horizontal overflow" do
    place = places(:one)
    place.update!(name: "Место на мобильной карте", description: "История места и его архитектуры. " * 120)
    [ 320, 390, 430 ].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 844, deviceScaleFactor: 1, mobile: true)
      visit root_path
      assert_equal width, page.evaluate_script("innerWidth")
      assert_selector ".mobile-map-header", visible: true
      assert_no_selector ".sidebar", visible: true
      assert_no_selector ".intro-stack", visible: true
      assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
      find("button[aria-label='Открыть меню']").click
      assert_selector "#mobile-map-navigation .menu-link", count: 6
      assert_selector ".mobile-menu-toggle[aria-expanded=true]"
      find("button[aria-label='Закрыть меню']").click
      assert_no_selector ".sidebar", visible: true
      assert_selector ".year-track button", text: "2000"
      click_button "1 год"
      assert_selector ".interval-buttons button[aria-pressed=true]", text: "1 год"
      find("summary", text: "Объекты на карте").click
      click_button place.name
      assert_selector ".map-page.article-open"
      assert_selector "#memory-article", visible: true
      assert_no_selector ".timeline", visible: true
      page.save_screenshot(Rails.root.join("tmp/screenshots/mobile-article-#{width}.png"))
      map_bounds = page.evaluate_script("JSON.stringify(document.querySelector('.map').getBoundingClientRect().toJSON())")
      assert_operator page.evaluate_script("document.querySelector('#memory-article').getBoundingClientRect().width"), :>=, width - 30
      page.execute_script("document.querySelector('.article-scroll').scrollTop = 500")
      assert_operator page.evaluate_script("document.querySelector('.article-scroll').scrollTop"), :>, 0
      assert_equal map_bounds, page.evaluate_script("JSON.stringify(document.querySelector('.map').getBoundingClientRect().toJSON())")
      assert_equal 0, page.evaluate_script("window.scrollY")
      find("button[aria-label='Закрыть статью']").click
      assert_no_selector "#memory-article", visible: true
      assert_selector ".timeline", visible: true
      page.save_screenshot(Rails.root.join("tmp/screenshots/mobile-map-#{width}.png"))
    end
  end
end
