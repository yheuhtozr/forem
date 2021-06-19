class CustomProfileField < ApplicationRecord
  include ActsAsProfileField

  belongs_to :profile

  validate :validate_maximum_count

  private

  # We allow a maximum of 5 custom profile fields per user
  def validate_maximum_count
    return if profile.custom_profile_fields.count < 5

    errors.add(:profile_id, I18n.t("models.custom_profile_field.maximum_number_of_custom_p"))
  end
end
