require "test_helper"

class UserAccountsTest < ActionDispatch::IntegrationTest
  def register(email: "reader@example.test", username: "reader")
    post user_registration_path, params: { user: { name: "Женя", username: username, email: email, password: "LongPassword123!", password_confirmation: "LongPassword123!" } }
  end

  test "registration signs in without granting administrator access" do
    get profile_path
    assert_redirected_to user_login_path
    assert_difference("User.count", 1) { register }
    assert_redirected_to profile_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Женя"
    assert_select ".profile-columns", 1
    get admin_places_path
    assert_redirected_to admin_login_path
    delete user_logout_path
    get profile_path
    assert_redirected_to user_login_path
    post user_login_path, params: { email: "reader@example.test", password: "wrong" }
    assert_response :unprocessable_content
    post user_login_path, params: { email: " READER@example.test ", password: "LongPassword123!" }
    assert_redirected_to profile_path
  end

  test "settings require password and submissions cannot set owner or moderation status" do
    register
    user = User.find_by!(username: "reader")
    patch profile_path, params: { current_password: "wrong", user: { email: "changed@example.test" } }
    assert_equal "reader@example.test", user.reload.email
    patch profile_path, params: { current_password: "LongPassword123!", user: { email: "changed@example.test", notification_preferences: { articles: "1" } } }
    assert_equal "changed@example.test", user.reload.email
    assert_equal "1", user.notification_preferences["articles"]
    assert_difference("ProfileSubmission.count", 1) do
      post profile_submissions_path, params: { profile_submission: { title: "Тихие дворы", kind: "route", status: "accepted", user_id: 99999 } }
    end
    submission = user.profile_submissions.last
    assert_equal "pending", submission.status
    assert_equal user.id, submission.user_id
    assert_no_difference("SavedPlace.count") { post "/saved_places", params: { place_id: places(:one).id } }
    assert_response :not_found
    assert_no_difference("SavedRoute.count") { post "/saved_routes", params: { route_key: "fire-1812.jpg" } }
    assert_response :not_found
    get admin_profile_submissions_path
    assert_redirected_to admin_login_path
    delete user_logout_path
    register(email: "other@example.test", username: "other")
    assert_no_difference("SavedPlace.count") { delete "/saved_places/1" }
    assert_response :not_found
  end

  test "invalid registration and duplicate normalized addresses are rejected" do
    register
    delete user_logout_path
    assert_no_difference("User.count") { register(email: "READER@example.test", username: "another") }
    assert_response :unprocessable_content
    assert_no_difference("User.count") do
      post user_registration_path, params: { user: { name: "Test", username: "test", email: "test@example.test", password: "short", password_confirmation: "short" } }
    end
    assert_response :unprocessable_content
  end
  test "only the author can moderate user proposals" do
    register
    user = User.find_by!(username: "reader")
    submission = user.profile_submissions.create!(kind: "photo", title: "Старый двор")
    patch admin_profile_submission_path(submission), params: { profile_submission: { status: "accepted" } }
    assert_redirected_to admin_login_path
    assert_equal "pending", submission.reload.status
    post admin_session_path, params: { email: "author@example.test", password: "test-author-password-123" }
    patch admin_profile_submission_path(submission), params: { profile_submission: { status: "accepted" } }
    assert_equal "accepted", submission.reload.status
    patch admin_profile_submission_path(submission), params: { profile_submission: { status: "invalid" } }
    assert_equal "accepted", submission.reload.status
  end
end
