module LocaleHelper
  def lang_name(code, fallback: false)
    if code.present?
      tag = code.to_s.downcase
      while tag.present?
        trans = begin
          I18n.translate!("languages.#{tag}", default: I18n.translate!(fallback ? "languages_fallback.#{tag}" : ""))
        rescue StandardError
          nil
        end
        return trans unless trans.nil? # rubocop:disable Layout/EmptyLineAfterGuardClause
        tag = tag.rpartition('-').first # rubocop:disable Style/StringLiterals
      end
      I18n.t("languages.mis", code: code)
    else
      I18n.t("languages.und")
    end
  end

  def lang_name!(code)
    lang_name(code, fallback: true)
  end

  # temporary href locale prefix solution
  def loc
    I18n.locale == I18n.default_locale ? "" : "/:#{I18n.locale}"
  end
end
