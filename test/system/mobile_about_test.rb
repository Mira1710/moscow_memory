require "application_system_test_case"

class MobileAboutTest < ApplicationSystemTestCase
  teardown { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }

  test "mobile about has a collage swipeable maps signup and menu" do
    [ 320, 390, 430 ].each do |width|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: width, height: 844, deviceScaleFactor: 1, mobile: true)
      visit about_path
      assert_selector ".about-mobile-header"
      assert_selector ".about-mobile-timeline"
      assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
      find("button[aria-label='Открыть меню']").click
      assert_selector "#about-navigation .menu-link", count: 6
      find("button[aria-label='Закрыть меню']").click
      assert_selector ".about-evidence-grid figure", count: 5
      page.execute_script("const main=document.querySelector('.about-page main'); main.scrollTop=document.querySelector('.about-map-story').offsetTop - 100")
      assert_selector ".about-map-slides"
      assert_equal "false", find(".about-how")["aria-hidden"]
      assert_equal "false", find(".about-timeline")["aria-hidden"]
      find("button[aria-label='Следующий слайд']").click
      assert_selector "[data-about-story-target='slideLabel']", text: "2 / 2"
      assert_operator page.evaluate_script("document.querySelector('.about-map-slides').scrollLeft"), :>, width / 2
      find("button[aria-label='Предыдущий слайд']").click
      assert_selector "[data-about-story-target='slideLabel']", text: "1 / 2"
      find(".about-map-slides").synchronize { raise Capybara::ExpectationNotMet unless page.evaluate_script("document.querySelector('.about-map-slides').scrollLeft") < 1 }
      page.save_screenshot(Rails.root.join("tmp/screenshots/about-mobile-#{width}.png"))
      page.execute_script("const main=document.querySelector('.about-page main'); main.scrollTop=main.scrollHeight")
      assert_selector ".about-launch-card input[type=email]"
      assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
    end
  end
end
