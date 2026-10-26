require "application_system_test_case"

class MapNavigationTest < ApplicationSystemTestCase
  test "marker opens right panel while map stays fixed and timeline switches intervals" do
    place = places(:one)
    place.update!(description: "История места. " * 200, category: "public_spaces", latitude: 55.75, longitude: 37.62)
    visit root_path
    assert_selector "[data-controller='memory-map']"
    click_button "Метки"
    assert_selector ".category-filter", count: 8
    assert page.evaluate_script("document.querySelector('.place-list').scrollHeight <= document.querySelector('.place-list').clientHeight + 1")
    # Deterministic substitute for the external provider: exercise our marker callback,
    # without consuming a real API key or depending on Yandex/network availability.
    page.execute_script <<~JS
      window.ymaps3 = {
        ready: Promise.resolve(),
        YMap: class {
          constructor(element, options) { this.element = element; this.zoom = options.location.zoom; }
          addChild(child) { if (child.button) { child.button.style.position = 'absolute'; child.button.style.left = '60%'; child.button.style.top = '50%'; this.element.append(child.button); } return this; }
          removeChild(child) { child.button?.remove(); return this; }
          update() {}
          destroy() {}
        },
        YMapDefaultSchemeLayer: class { constructor(options) { window.testMapCustomization = options.customization; } },
        YMapDefaultFeaturesLayer: class {},
        YMapMarker: class {
          constructor(options, button) { this.button = button; window.testMarkerCoordinates = options.coordinates; }
        }
      };
      const controller = window.Stimulus.getControllerForElementAndIdentifier(document.querySelector('[data-controller="memory-map"]'), 'memory-map');
      controller.keyValue = 'system-test';
      controller.start();
    JS
    assert_selector ".memory-map-marker"
    assert_equal [37.62, 55.75], page.evaluate_script("window.testMarkerCoordinates")
    assert_equal "#80c2e9", page.evaluate_script("window.testMapCustomization[1].stylers[0].color")
    page.save_screenshot(Rails.root.join("tmp/screenshots/timeline-grid.png"))
    bounds = page.evaluate_script("JSON.stringify(document.querySelector('.map').getBoundingClientRect().toJSON())")
    all(".memory-map-marker").last.click
    assert_selector "#memory-article", visible: true
    assert_equal bounds, page.evaluate_script("JSON.stringify(document.querySelector('.map').getBoundingClientRect().toJSON())")
    assert_operator page.evaluate_script("document.querySelector('#memory-article').getBoundingClientRect().left"), :>, 600
    find("body").send_keys(:escape)
    assert_no_selector "#memory-article", visible: true
    click_button "Интервал"
    [ [ "50 лет", "1950" ], [ "10 лет", "1940" ], [ "1 год", Date.current.year.to_s ] ].each do |label, year|
      click_button label
      assert_selector ".year-track button", text: year
      assert_selector "button[aria-pressed='true']", text: label
    end
  end

  test "about page and splash retain navigation on a narrow screen" do
    page.current_window.resize_to(390, 844)
    visit about_path
    assert_selector "#about-title"
    assert_selector ".about-scene", count: 5, visible: :all
    assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - window.innerWidth)")
    visit root_path
    assert_selector ".map"
    assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - window.innerWidth)")
  end
end
