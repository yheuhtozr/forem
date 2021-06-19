class ApiSecret < ApplicationRecord
  has_secure_token :secret

  belongs_to :user

  validates :description, presence: true, length: { maximum: 300 }
  validate :user_api_secret_count

  private

  def user_api_secret_count
    return if user && user.api_secrets.count < 20

    errors.add(:user, I18n.t("models.api_secret.api_secret_limit_of_20_per"))
  end
end
