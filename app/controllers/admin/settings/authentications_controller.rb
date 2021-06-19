module Admin
  module Settings
    class AuthenticationsController < Admin::ApplicationController
      def create
        result = ::Authentication::SettingsUpsert.call(settings_params)

        if result.success?
          Audit::Logger.log(:internal, current_user, params.dup)
          redirect_to admin_config_path, notice: I18n.t("common.success_settings")
        else
          redirect_to admin_config_path, alert: I18n.t("common.error_friendly", errors: result.errors.to_sentence)
        end
      end

      def settings_params
        params
          .require(:settings_authentication)
          .permit(*::Settings::Authentication.keys, :auth_providers_to_enable)
      end
    end
  end
end
