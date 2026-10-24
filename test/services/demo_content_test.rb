require "test_helper"

class DemoContentTest < ActiveSupport::TestCase
  test "seed repeats preserve edits, uploads, removed periods and unrelated articles" do
    original = places(:one)
    assert_difference("Place.count", 3) { assert_equal 3, DemoContent.load! }
    place = Place.find_by!(seed_key: "demo-melnikov")
    File.open(Rails.root.join("test/fixtures/files/editor.png")) do |photo|
      place.update!(name: "Авторское название", description: "Мой текст", image: photo)
    end
    image_path = place.image.path
    place.historical_states.first.destroy!
    state_count = HistoricalState.count
    assert_no_difference("Place.count") { assert_equal 0, DemoContent.load! }
    assert_equal "Авторское название", place.reload.name
    assert_equal "Мой текст", place.description
    assert_equal image_path, place.image.path
    assert File.file?(image_path)
    assert_equal state_count, HistoricalState.count
    assert Place.exists?(original.id)
    assert Place.where(seed_key: DemoContent.entries.pluck(:seed_key)).all? { |item| item.historical_states.any? && item.sources.present? }
  end
end
