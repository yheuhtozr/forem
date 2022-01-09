class ValidDomainCsvValidator < ActiveModel::EachValidator
  VALID_DOMAIN = /^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$/

  def validate_each(record, attribute, value)
    return unless value

    return if value.all? { |domain| domain.match?(VALID_DOMAIN) }

    record.errors.add(attribute,
                      options[:message] || I18n.t("validators.valid_domain_csv_validator.must_be_a_comma_separated"))
  end
end
