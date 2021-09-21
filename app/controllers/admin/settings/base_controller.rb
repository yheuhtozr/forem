module Admin
  module Settings
    class BaseController < Admin::ApplicationController
      before_action :extra_authorization_and_confirmation, only: [:create]

      def create
        result = upsert_config(settings_params)

        if result.success?
          Audit::Logger.log(:internal, current_user, params.dup)
          redirect_to admin_config_path, notice: I18n.t("common.success_settings")
        else
          redirect_to admin_config_path, alert: I18n.t("common.error_friendly", errors: result.errors.to_sentence)
        end
      end

      private

      def extra_authorization_and_confirmation
        not_authorized unless current_user.has_role?(:super_admin)
        raise_confirmation_mismatch_error unless confirmation_text_valid?
      end

      def confirmation_text_valid?
        params.require(:confirmation) ==
          I18n.t("admin.settings_controller.my_username_is_and_this_ac", current_user_username: current_user.username)
      end

      def raise_confirmation_mismatch_error
        raise ActionController::BadRequest.new, I18n.t("admin.settings_controller.the_confirmation_key_does")
      end

      # Override this method if you need to call a custom class for upserting.
      # Ideally such a class eventually calls out to Settings::Upsert and returns
      # the result of that service.
      def upsert_config(settings)
        ::Settings::Upsert.call(settings, authorization_resource)
      end

      # Override this if you need additional params or need to make other changes,
      # e.g. a different require key.
      def settings_params
        params
          .require(:"settings_#{authorization_resource.name.demodulize.underscore}")
          .permit(*authorization_resource.keys)
      end

      def authorize_super_admin
        raise Pundit::NotAuthorizedError unless current_user.has_role?(:super_admin)
      end
    end
  end
end
