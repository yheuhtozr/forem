module Admin
  # This controller is solely responsible for rendering the settings page at
  # /admin/customization/config. The actual updates get handled by the settings
  # controllers in the Admin::Settings namespace.
  class SettingsController < Admin::ApplicationController
    before_action :extra_authorization_and_confirmation, only: [:create]

    layout "admin"

    def show
      @confirmation_text =
        "My username is @#{current_user.username} and this action is 100% safe and appropriate."
    end

    private

    def extra_authorization_and_confirmation
      not_authorized unless current_user.has_role?(:super_admin)
      raise_confirmation_mismatch_error if params.require(:confirmation) != confirmation_text
    end

    def confirmation_text
      I18n.t("admin.settings_controller.my_username_is_and_this_ac", current_user_username: current_user.username)
    end

    def raise_confirmation_mismatch_error
      raise ActionController::BadRequest.new, I18n.t("admin.settings_controller.the_confirmation_key_does")
    end
  end
end
