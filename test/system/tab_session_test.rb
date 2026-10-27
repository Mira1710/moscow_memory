require "application_system_test_case"

class TabSessionTest < ApplicationSystemTestCase
  test "both accounts survive refresh and signing into the other account" do
    User.create!(name: "Reader", username: "tab_reader", email: "tab@example.test", password: "12345678", password_confirmation: "12345678")
    visit admin_login_path
    fill_in "Почта", with: "author@example.test"
    fill_in "Пароль", with: "test-author-password-123"
    click_button "Войти"
    assert_selector '.admin-shell[data-account-role="admin"]'
    page.refresh
    assert_selector '.admin-shell[data-account-role="admin"]'
    assert_current_path admin_places_path

    visit user_login_path
    fill_in "Почта", with: "tab@example.test"
    fill_in "Пароль", with: "12345678"
    click_button "Войти"
    assert_selector ".profile-summary"
    page.refresh
    assert_selector ".profile-summary"
    assert_current_path profile_path
    visit admin_places_path
    assert_selector '.admin-shell[data-account-role="admin"]'
    page.refresh
    assert_current_path admin_places_path
    assert_selector '.admin-shell[data-account-role="admin"]'

    new_tab = open_new_window
    within_window new_tab do
      visit admin_places_path
      assert_current_path admin_login_path
    end
    within_window new_tab do
      visit profile_path
      assert_current_path user_login_path
    end
    new_tab.close
  end
  test "closing an authenticated tab requires login in a newly opened tab" do
    authenticated_tab = open_new_window
    within_window authenticated_tab do
      visit admin_login_path
      fill_in "Почта", with: "author@example.test"
      fill_in "Пароль", with: "test-author-password-123"
      click_button "Войти"
      assert_selector '.admin-shell[data-account-role="admin"]'
    end
    authenticated_tab.close
    fresh_tab = open_new_window
    within_window fresh_tab do
      visit admin_places_path
      assert_current_path admin_login_path
    end
    fresh_tab.close
  end
end
