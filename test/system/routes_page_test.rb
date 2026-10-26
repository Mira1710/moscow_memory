require "application_system_test_case"

class RoutesPageTest < ApplicationSystemTestCase
  teardown { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }

  test "route sections expand smoothly on hover and show metadata on keyboard focus" do
    visit walking_routes_path
    assert_selector ".route-section", count: 3
    assert_selector ".route-card", count: 6
    section = all(".route-section")[1]
    card = section.first(".route-card")
    initial_width = card.native.rect.width
    page.save_screenshot(Rails.root.join("tmp/screenshots/routes-desktop.png"))
    section.hover
    assert_selector ".route-card-meta", visible: true, minimum: 2
    assert_operator card.native.rect.width, :>, initial_width
    section.synchronize do
      color = section.find("h2").style("color")["color"].scan(/[\d.]+/).first(3).map(&:to_i)
      raise Capybara::ExpectationNotMet, "Heading has not finished changing color" unless color == [ 183, 17, 22 ]
    end
    page.save_screenshot(Rails.root.join("tmp/screenshots/routes-hover.png"))
    find(".sidebar").hover
    card.send_keys(:tab)
    assert_selector ".route-card:focus"
    assert_selector ".route-card-meta", visible: true, minimum: 2
    assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
  end

  test "mobile routes show all cards and a working navigation menu" do
    [ 320, 390, 768 ].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 844, deviceScaleFactor: 1, mobile: true)
      visit walking_routes_path
      assert_selector ".route-card", count: 6
      assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
      if width < 768
        find("button[aria-label='Открыть меню']").click
        assert_selector "#routes-navigation .menu-link", count: 6
        find("button[aria-label='Закрыть меню']").click
        assert_no_selector ".sidebar", visible: true
      end
      page.save_screenshot(Rails.root.join("tmp/screenshots/routes-#{width}.png"))
    end
  end
end
