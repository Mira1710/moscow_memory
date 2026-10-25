require "test_helper"

class LaunchSubscriptionsTest < ActionDispatch::IntegrationTest
  test "valid email and consent persist only once with original consent date" do
    assert_difference("LaunchSubscription.count", 1) do
      post launch_subscriptions_path, params: { email: "  Reader@Example.test ", consent: "1", source: "about" }, as: :json
    end
    assert_response :success
    subscription = LaunchSubscription.find_by!(email: "reader@example.test")
    accepted_at = subscription.consent_accepted_at
    assert_equal "about", subscription.source
    travel 1.day do
      assert_no_difference("LaunchSubscription.count") do
        post launch_subscriptions_path, params: { email: "READER@example.test", consent: true, source: "map" }, as: :json
      end
    end
    assert_response :success
    assert_equal accepted_at, subscription.reload.consent_accepted_at
    assert_equal "about", subscription.source
  end

  test "invalid addresses and absent consent are rejected without saving" do
    [ { email: "bad-address", consent: "1" }, { email: "person@example.test", consent: "0" },
      { email: "person@example.test" }, { email: "", consent: true } ].each do |attributes|
      assert_no_difference("LaunchSubscription.count") { post launch_subscriptions_path, params: attributes, as: :json }
      assert_response :unprocessable_content
    end
  end

  test "subscriber list requires author login and exposes count only inside admin" do
    LaunchSubscription.create!(email: "private@example.test", consent_accepted_at: Time.current, source: "map")
    get admin_launch_subscriptions_path
    assert_redirected_to admin_login_path
    assert_not_includes response.body, "private@example.test"
    post admin_session_path, params: { email: "author@example.test", password: "test-author-password-123" }
    get admin_launch_subscriptions_path
    assert_response :success
    assert_includes response.body, "private@example.test"
    assert_select ".subscription-count strong", "1"
    get root_path
    assert_not_includes response.body, "private@example.test"
  end
end
