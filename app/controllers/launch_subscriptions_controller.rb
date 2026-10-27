class LaunchSubscriptionsController < ApplicationController
  rate_limit to: 30, within: 3.minutes, only: :create,
    with: -> { render json: { error: "Слишком много попыток. Попробуйте через несколько минут." }, status: :too_many_requests }

  def create
    unless [ true, "1", "true" ].include?(params[:consent])
      return render json: { error: "Подтвердите согласие на обработку почты для уведомления о запуске." }, status: :unprocessable_content
    end

    email = params[:email].to_s.strip.downcase
    subscription = LaunchSubscription.find_or_initialize_by(email: email)
    if subscription.new_record?
      subscription.assign_attributes(consent_accepted_at: Time.current, source: params[:source] == "about" ? "about" : "map")
      subscription.save!
    end
    render json: { saved: true }
  rescue ActiveRecord::RecordNotUnique
    render json: { saved: true }
  rescue ActiveRecord::RecordInvalid
    render json: { error: "Проверьте адрес электронной почты." }, status: :unprocessable_content
  end
end
