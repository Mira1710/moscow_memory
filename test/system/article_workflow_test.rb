require "application_system_test_case"

class ArticleWorkflowTest < ApplicationSystemTestCase
  test "author creates edits publishes and deletes an illustrated article" do
    visit admin_login_path
    fill_in "Почта", with: "author@example.test"
    fill_in "Пароль", with: "test-author-password-123"
    click_button "Войти"
    click_link "+ Добавить место и статью"
    fill_in "Название места", with: "Место для проверки"
    select "Городские пространства", from: "Категория метки"
    fill_in "Широта", with: "55.75"
    fill_in "Долгота", with: "37.62"
    fill_in "Основной текст статьи", with: "Проверка публикации статьи. " * 120
    attach_file "place_image", Rails.root.join("test/fixtures/files/editor.png")
    within first(".editor-period") do
      fill_in "Название периода", with: "Первый период"
      fill_in "Год начала", with: "1900"
      fill_in "Текст периода", with: "История места"
      check "Показывать блок «Сохранившееся»"
      fill_in "Сохранившееся: текст", with: "Сохранившаяся часть"
    end
    click_button "Сохранить статью"
    assert_text "Объект и статья сохранены."
    place = Place.find_by!(name: "Место для проверки")
    assert_selector ".article-cover img"
    first(:link, "Редактировать статью").click
    fill_in "Название места", with: "Обновлённое место"
    click_button "Сохранить статью"
    assert_text "Изменения статьи сохранены."

    visit root_path
    page.execute_script("window.Stimulus.getControllerForElementAndIdentifier(document.querySelector('[data-controller=memory-map]'), 'memory-map').show(arguments[0])", place.id.to_s)
    assert_selector "#memory-article", visible: true
    within "#memory-article" do
      assert_text(/Обновлённое место/i)
      assert_selector ".article-cover img"
    end
    assert_equal 0, page.evaluate_script("window.scrollY")
    page.execute_script("document.querySelector('.article-scroll').scrollTop = 400")
    assert_operator page.evaluate_script("document.querySelector('.article-scroll').scrollTop"), :>, 0
    assert_equal 0, page.evaluate_script("window.scrollY")
    find("button[aria-label='Закрыть статью']").click
    assert_no_selector "#memory-article", visible: true

    visit admin_place_path(place)
    accept_confirm { click_button "Удалить объект и его статью" }
    assert_text "Объект удалён."
    assert_not Place.exists?(place.id)
    assert_not HistoricalState.exists?(place_id: place.id)
    click_button "Выйти из админки"
    assert_current_path admin_login_path
    visit new_admin_place_path
    assert_current_path admin_login_path
  end
end
