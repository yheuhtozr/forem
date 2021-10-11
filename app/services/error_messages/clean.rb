module ErrorMessages
  class Clean
    FRONTMATTER_ERROR = /expected key while parsing a block mapping at line/

    def self.call(error_message)
      return error_message unless error_message.match?(FRONTMATTER_ERROR)

      I18n.t("services.error_messages.clean.there_was_a_problem_parsin", s: Settings::General.email_addresses[:default])
    end
  end
end
