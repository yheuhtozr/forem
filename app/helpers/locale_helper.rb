module LocaleHelper
  def lang_name(code)
    if code.present?
      tag = code.to_s.downcase
      while tag.present?
        trans = R18n.t.languages[tag]
        return trans.to_s if trans.translated? # rubocop:disable Layout/EmptyLineAfterGuardClause
        tag = tag.rpartition('-').first # rubocop:disable Style/StringLiterals
      end
      R18n.t.languages.mis(code: code).to_s
    else
      R18n.t.languages.und.to_s
    end
  end

  # temporary href locale prefix solution
  def loc
    I18n.locale == I18n.default_locale ? "" : "/:#{I18n.locale}"
  end
end
