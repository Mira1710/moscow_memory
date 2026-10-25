class LaunchSubscription < ApplicationRecord
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, length: { maximum: 254 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :consent_accepted_at, presence: true
  validates :source, inclusion: { in: %w[map about] }
end
