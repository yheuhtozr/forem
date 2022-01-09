module Authentication
  module Errors
    PREVIOUSLY_SUSPENDED_MESSAGE = "".freeze

    class Error < StandardError
    end

    class ProviderNotFound < Error
    end

    class ProviderNotEnabled < Error
    end

    class PreviouslySuspended < Error
      def message
        I18n.t("errors.authentication.errors.suspended",
               community_name: Settings::Community.community_name,
               community_email: ForemInstance.email)
      end
    end
  end
end
