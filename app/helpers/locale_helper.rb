module LocaleHelper
  def lang_name(code)
    if code.present?
      tag = code.to_s.downcase
      while tag.present?
        trans = R18n.t.languages[tag]
        return trans if trans.translated? # rubocop:disable Layout/EmptyLineAfterGuardClause
        tag = tag.rpartition('-').first # rubocop:disable Style/StringLiterals
      end
      R18n.t.languages.mis(code: code)
    else
      R18n.t.languages.und
    end
  end
end
