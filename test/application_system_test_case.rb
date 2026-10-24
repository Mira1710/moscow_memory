require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  setup { page.current_window.resize_to(1440, 1000) }

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1000 ]
end
