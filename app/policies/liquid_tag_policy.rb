# Intentionally not inheriting from ApplicationPolicy because liquid tags behave
# differently than the typical Model/Controller dynamic that Pundit assumes.
class LiquidTagPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

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
    record.class::VALID_ROLES.any? { |valid_role| user_has_valid_role?(valid_role) }
  end

  def user_has_valid_role?(valid_role)
    # Splat array for single resource roles
    user.has_role?(*Array(valid_role))
  end
end
