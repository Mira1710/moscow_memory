require "application_system_test_case"

class AboutMotionTest < ApplicationSystemTestCase
  def scroll_story(expression)
    page.execute_script("const main = document.querySelector('.about-page main'); main.scrollTop = #{expression};")
  end

  test "fixed frame and inner scroll animations reverse without overlapping outer scenes" do
    visit about_path
    assert_selector "#about-title"
    title_top = find("#about-title").native.rect.y
    initial_width = find(".about-time-bridge").native.rect.width
    scroll_story("main.querySelector('.about-intro').offsetHeight * .32")
    find(".about-intro").synchronize do
      raise Capybara::ExpectationNotMet unless page.evaluate_script("Number(document.querySelector('.about-intro').style.getPropertyValue('--intro-progress'))") > 0.5
    end
    assert_operator find(".about-time-bridge").native.rect.width, :>, initial_width
    assert_operator find("#about-title").native.rect.y, :>, title_top
    page.save_screenshot(Rails.root.join("tmp/screenshots/about-intro-expanded.png"))
    assert_equal "relative", find(".about-intro").style("position")["position"]
    scroll_story("main.querySelector('.about-history').offsetTop + 100")
    image = find(".about-evidence-grid")
    image.synchronize do
      raise Capybara::ExpectationNotMet unless image.style("opacity")["opacity"].to_f > 0
    end
    tops = all(".about-evidence-grid .about-image").map { |item| item.native.rect.y }
    assert_operator tops.max - tops.min, :<=, 1
    first_x = image.style("transform")["transform"]
    scroll_story("main.querySelector('.about-history').offsetTop + 350")
    image.synchronize { raise Capybara::ExpectationNotMet if first_x == image.style("transform")["transform"] }
    page.save_screenshot(Rails.root.join("tmp/screenshots/about-diagonal-images.png"))
    scroll_story("main.querySelector('.about-history').offsetTop + 100")
    image.synchronize { raise Capybara::ExpectationNotMet unless first_x == image.style("transform")["transform"] }
    scroll_story("main.querySelector('.about-map-story').offsetTop + (main.querySelector('.about-map-story').offsetHeight - main.clientHeight) * .5")
    assert_selector ".about-timeline[aria-hidden=false]"
    assert_selector ".about-how[aria-hidden=true]", visible: :all
    page.save_screenshot(Rails.root.join("tmp/screenshots/about-map-change.png"))
    scroll_story("main.querySelector('.about-map-story').offsetTop + (main.querySelector('.about-map-story').offsetHeight - main.clientHeight) * .95")
    assert_selector ".about-more[aria-hidden=false]"
    assert_selector ".about-timeline[aria-hidden=true]", visible: :all
    visual = find(".about-more .about-launch-visual").native.rect
    stage = find(".about-map-stage").native.rect
    assert_in_delta stage.y + stage.height / 2.0, visual.y + visual.height / 2.0, 3
    page.save_screenshot(Rails.root.join("tmp/screenshots/about-final-overlay.png"))
    scroll_story("main.querySelector('.about-map-story').offsetTop")
    assert_selector ".about-how[aria-hidden=false]"
    assert_selector ".about-timeline[aria-hidden=true]", visible: :all
    assert_equal "200", page.evaluate_script("getComputedStyle(document.querySelector('.about-intro-copy')).fontWeight")
  end

  test "reduced motion makes both map frames readable in normal flow" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-reduced-motion", value: "reduce" } ])
    visit about_path
    assert_selector ".about-how[aria-hidden=false]"
    assert_selector ".about-timeline[aria-hidden=false]"
    assert_selector ".about-more[aria-hidden=false]"
    assert_equal "relative", find(".about-map-stage").style("position")["position"]
  ensure
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [])
  end
end
