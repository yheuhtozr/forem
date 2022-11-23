module LocaleHelper
  def lang_name(code, fallback: false, locale: nil)
    if code.present?
      tag = code.to_s.downcase
      while tag.present?
        trans = begin
          I18n.t!("languages.#{tag}", locale: locale)
        rescue StandardError
          # rubocop:disable Metrics/BlockNesting
          if fallback
            begin
              I18n.t!("languages_fallback.#{tag}", locale: locale)
            rescue StandardError
              nil
            end
          end
          # rubocop:enable Metrics/BlockNesting
        end
        return trans unless trans.nil? # rubocop:disable Layout/EmptyLineAfterGuardClause
        tag = tag.rpartition('-').first # rubocop:disable Style/StringLiterals
      end
      I18n.t("languages.mis", code: code, locale: locale)
    else
      I18n.t("languages.und", locale: locale)
    end
  end

  def lang_name!(code, locale: nil)
    lang_name(code, fallback: true, locale: locale)
  end

  # temporary href locale prefix solution
  def loc(path, locale = nil)
    possible_locale = %r{\A/:[^/]*}.match(path).to_a[0].to_s # use the locale route format on this site
    plain_path = path.delete_prefix possible_locale
    explicit_locale = locale || I18n.locale

    "#{root_path locale: explicit_locale if locale || I18n.locale != I18n.default_locale}#{plain_path}"
  end
end
