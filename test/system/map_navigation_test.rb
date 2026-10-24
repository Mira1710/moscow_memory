require "application_system_test_case"

class MapNavigationTest < ApplicationSystemTestCase
  test "marker opens right panel while map stays fixed and timeline switches intervals" do
    place = places(:one)
    place.update!(description: "История места. " * 200, category: "public_spaces", latitude: 55.75, longitude: 37.62)
    visit root_path
    assert_selector "[data-controller='memory-map']"
    # Deterministic substitute for the external provider: exercise our marker callback,
    # without consuming a real API key or depending on Yandex/network availability.
    page.execute_script <<~JS
      window.ymaps = {
        ready: callback => callback(),
        Map: class {
          constructor(element) {
            this.behaviors = { disable() {} };
            this.geoObjects = {
              contains: marker => marker.button.isConnected,
              add: marker => element.append(marker.button),
              remove: marker => marker.button.remove()
            };
          }
          destroy() {}
        },
        Placemark: class {
          constructor() {
            this.button = document.createElement('button');
            this.button.textContent = 'Проверочная метка';
            this.button.style.cssText = 'position:absolute;left:60%;top:50%';
            this.events = { add: (event, callback) => this.button.addEventListener(event, callback) };
          }
        }
      };
      const controller = window.Stimulus.getControllerForElementAndIdentifier(document.querySelector('[data-controller="memory-map"]'), 'memory-map');
      controller.keyValue = 'system-test';
      controller.start();
    JS
    assert_selector ".map button", text: "Проверочная метка"
    bounds = page.evaluate_script("JSON.stringify(document.querySelector('.map').getBoundingClientRect().toJSON())")
    all(".map button").last.click
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
    assert_selector ".about-scene", count: 5
    assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - window.innerWidth)")
    visit root_path
    assert_selector ".map"
    assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - window.innerWidth)")
  end
end
