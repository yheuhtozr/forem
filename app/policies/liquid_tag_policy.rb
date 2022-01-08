# This Policy is responsible for enforcing weither or not the user can utilize
# the given liquid tag.
#
# @note Intentionally not inheriting from ApplicationPolicy because liquid tags
#       behave differently than the typical Model/Controller dynamic that Pundit
#       assumes.
class LiquidTagPolicy
  attr_reader :user, :liquid_tag

  # @param user [User]
  # @param liquid_tag [LiquidTagBase]
  def initialize(user, liquid_tag)
    @user = user
    @liquid_tag = liquid_tag
  end

  # Check if the given #user can utilize the given #liquid_tag
  #
  # @return [TrueClass] if the given liquid_tag is available to the user.

  # @raise [Pundit::NotAuthorizedError] if the liquid tag is not available to
  #        the given user.
  def initialize?
    return true unless record.class.const_defined?("VALID_ROLES")
    raise Pundit::NotAuthorizedError, I18n.t("policies.liquid_tag_policy.no_user_found") unless user

    # Manually raise error to use a custom error message
    unless user_allowed_to_use_tag?
      raise Pundit::NotAuthorizedError,
            I18n.t("policies.liquid_tag_policy.user_is_not_permitted_to_u")
    end

    true
  end

  private

  def user_allowed_to_use_tag?
    user.public_send(liquid_tag.user_authorization_method_name)
  end
end
