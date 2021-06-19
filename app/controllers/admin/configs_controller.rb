module Admin
  class ConfigsController < Admin::SettingsController
    include SettingsParams

    def create
      result = ::Settings::Upsert.call(settings_params)
      if result.success?
        Audit::Logger.log(:internal, current_user, params.dup)
        bust_content_change_caches
        redirect_to admin_config_path, notice: I18n.t("common.success_settings")
      else
        redirect_to admin_config_path, alert: I18n.t("common.error_friendly", errors: result.errors.to_sentence)
      end
    end
  end
end
