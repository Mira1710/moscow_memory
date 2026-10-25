require "application_system_test_case"

class LaunchSignupTest < ApplicationSystemTestCase
  teardown { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }

  test "map and mobile about signup show confirmation only after persisting email" do
    [ root_path, about_path ].each_with_index do |path, index|
      page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: index.zero? ? 1440 : 390, height: 1000, deviceScaleFactor: 1, mobile: !index.zero?)
      visit path
      within ".launch-signup" do
        assert_button "Узнать о запуске", disabled: true
        fill_in "Электронная почта", with: "visitor#{index}@example.test"
        find("input[type=checkbox]").check
        click_button "Узнать о запуске"
        assert_selector "dialog[open]"
        assert_text "Спасибо за интерес!"
        assert_text "уведомим вас в числе первых"
        assert LaunchSubscription.exists?(email: "visitor#{index}@example.test")
        page.save_screenshot(Rails.root.join("tmp/screenshots/signup-#{index}.png"))
        click_button "Будем ждать!"
        assert_no_selector "dialog[open]"
        assert_button "Узнать о запуске", disabled: true
      end
    end
  end

  test "connection failure shows error and allows retry without a success popup" do
    visit root_path
    page.execute_script("window.originalFetch = window.fetch; window.fetch = () => Promise.reject(new TypeError('offline'))")
    within ".launch-signup" do
      fill_in "Электронная почта", with: "retry@example.test"
      find("input[type=checkbox]").check
      click_button "Узнать о запуске"
      assert_text "Нет соединения. Почта не сохранена"
      assert_no_selector "dialog[open]"
      assert_not LaunchSubscription.exists?(email: "retry@example.test")
      page.execute_script("window.fetch = window.originalFetch")
      click_button "Узнать о запуске"
      assert_selector "dialog[open]"
      assert LaunchSubscription.exists?(email: "retry@example.test")
    end
  end
end
