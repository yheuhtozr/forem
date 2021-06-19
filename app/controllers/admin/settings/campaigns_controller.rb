module Admin
  module Settings
    class CampaignsController < Admin::ApplicationController
      def create
        result = ::Campaigns::SettingsUpsert.call(settings_params)

        if result.success?
          Audit::Logger.log(:internal, current_user, params.dup)
          redirect_to admin_config_path, notice: I18n.t("common.success_settings")
        else
          redirect_to admin_config_path, alert: I18n.t("common.error_friendly", erros: result.errors.to_sentence)
        end
      end

      def settings_params
        params
          .require(:settings_campaign)
          .permit(*::Settings::Campaign.keys)
      end
    end
  end
end
