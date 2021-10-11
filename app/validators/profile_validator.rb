class ProfileValidator < ActiveModel::Validator
  SUMMARY_ATTRIBUTE = "summary".freeze
  MAX_SUMMARY_LENGTH = 200

  MAX_TEXT_AREA_LENGTH = 200
  MAX_TEXT_FIELD_LENGTH = 100

  HEX_COLOR_REGEXP = /^#?(?:\h{6}|\h{3})$/.freeze

  def self.errors
    {
      color_field: I18n.t("validators.profile_validator.is_not_a_valid_hex_color"),
      text_area: I18n.t("validators.profile_validator.is_too_long_maximum",
                        max_text_area_length: MAX_TEXT_AREA_LENGTH),
      text_field: I18n.t("validators.profile_validator.is_too_long_maximum2",
                         max_text_field_length: MAX_TEXT_FIELD_LENGTH)
    }.with_indifferent_access
  end

  def validate(record)
    # NOTE: @citizen428 The summary is a base profile field, which we add to all
    # new Forem instances, so it should be safe to validate. The method itself
    # also guards against the field's absence.
    record.errors.add(:summary, I18n.t("validators.profile_validator.is_too_long")) if summary_too_long?(record)

    ProfileField.all.each do |field|
      attribute = field.attribute_name
      next if attribute == SUMMARY_ATTRIBUTE # validated above
      next unless record.respond_to?(attribute) # avoid caching issues
      next if __send__("#{field.input_type}_valid?", record, attribute)

      record.errors.add(attribute, errors[field.input_type])
    end
  end

  private

  def summary_too_long?(record)
    return if record.summary.blank?

    # Grandfather in people who had a too long summary before
    previous_summary = record.summary_was
    return if previous_summary && previous_summary.size > MAX_SUMMARY_LENGTH

    record.summary.size > MAX_SUMMARY_LENGTH
  end

  def check_box_valid?(_record, _attribute)
    true # checkboxes are always valid
  end

  def text_area_valid?(record, attribute)
    text = record.public_send(attribute)
    text.nil? || text.size <= MAX_TEXT_AREA_LENGTH
  end

  def text_field_valid?(record, attribute)
    text = record.public_send(attribute)
    text.nil? || text.size <= MAX_TEXT_FIELD_LENGTH
  end
end
