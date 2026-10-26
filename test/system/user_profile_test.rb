require "application_system_test_case"

class UserProfileTest < ApplicationSystemTestCase
  teardown { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }
  test "reader registers submits material saves settings and logs out" do
    visit user_registration_path
    fill_in "Имя", with: "Женя"
    fill_in "Ник (латинские буквы, цифры и _)", with: "mosknow"
    fill_in "Почта", with: "profile@example.test"
    fill_in "Пароль — от 12 символов", with: "LongPassword123!"
    fill_in "Повторите пароль", with: "LongPassword123!"
    click_button "Зарегистрироваться"
    assert_current_path profile_path
    assert_selector "h1", text: "ЖЕНЯ"
    click_link "Предложить маршрут"
    fill_in "Название", with: "Тихие дворы"
    fill_in "Описание, адрес, источники или ссылка на запись", with: "Прогулка по Москве"
    click_button "Отправить материал"
    assert_selector ".profile-item h4", text: "ТИХИЕ ДВОРЫ"
    page.save_screenshot(Rails.root.join("tmp/screenshots/profile-desktop.png"))
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 1, mobile: true)
    visit profile_path
    assert_equal 0, page.evaluate_script("Math.max(0, document.documentElement.scrollWidth - innerWidth)")
    find("button[aria-label='Открыть меню']").click
    assert_selector "#profile-navigation .menu-link", count: 6
    find("button[aria-label='Закрыть меню']").click
    page.save_screenshot(Rails.root.join("tmp/screenshots/profile-mobile.png"))
    click_button "Выйти"
    assert_current_path user_login_path
  end
end
