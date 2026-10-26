class User < ApplicationRecord
  has_secure_password
  normalizes :email, :username, with: ->(value) { value.strip.downcase }
  has_many :profile_submissions, dependent: :destroy
  has_many :saved_routes, dependent: :destroy
  has_many :saved_places, dependent: :destroy
  has_many :favorite_places, through: :saved_places, source: :place
  validates :password_confirmation, presence: true, if: -> { password.present? }
  validates :name, presence: true, length: { maximum: 80 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]{3,30}\z/, message: "— от 3 до 30 латинских букв, цифр или _" }
  validates :password, length: { minimum: 12, maximum: 72 }, if: -> { new_record? || password.present? }
end
