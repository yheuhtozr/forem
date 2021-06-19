module Admin
  module Settings
    class RateLimitsController < Admin::ApplicationController
      def create
        result = ::RateLimits::SettingsUpsert.call(settings_params)

        if result.success?
          Audit::Logger.log(:internal, current_user, params.dup)
          redirect_to admin_config_path, notice: I18n.t("common.success_settings")
        else
          redirect_to admin_config_path, alert: I18n.t("common.error_friendly", errors: result.errors.to_sentence)
        end
      end

      def settings_params
        params
          .require(:settings_rate_limit)
          .permit(*::Settings::RateLimit.keys)
      end
    end
  end
end
