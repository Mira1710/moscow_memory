require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  setup do
    @original_maps_key = ENV.delete("YANDEX_MAPS_API_KEY")
    page.current_window.resize_to(1440, 1000)
  end

  teardown do
    ENV["YANDEX_MAPS_API_KEY"] = @original_maps_key
  end

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1000 ]
end
