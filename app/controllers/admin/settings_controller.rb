module Admin
  class SettingsController < Admin::ApplicationController
    before_action :extra_authorization_and_confirmation, only: [:create]

    layout "admin"

    def create; end

    def show
      @confirmation_text = confirmation_text
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
