class LiquidTagBase < Liquid::Tag
  def self.script
    ""
  end

  def initialize(_tag_name, _content, parse_context)
    super
    validate_contexts
    # This check issues DB queries so we keep it as the last one
    Pundit.authorize(
      parse_context.partial_options[:user],
      self,
      :initialize?,
      policy_class: LiquidTagPolicy,
    )
  end

  def strip_tags(string)
    ActionController::Base.helpers.strip_tags(string).strip
  end

  private

  def validate_contexts
    return unless self.class.const_defined? "VALID_CONTEXTS"

    source = parse_context.partial_options[:source]
    raise LiquidTags::Errors::InvalidParseContext, I18n.t("liquid_tags.liquid_tag_base.no_source_found") unless source

    is_valid_source = self.class::VALID_CONTEXTS.include? source.class.name
    return if is_valid_source

    valid_contexts = self.class::VALID_CONTEXTS.map(&:pluralize).join(", ")
    invalid_source_error_msg = I18n.t("liquid_tags.liquid_tag_base.invalid_context_this_liqui",
                                      valid_contexts: valid_contexts)
    raise LiquidTags::Errors::InvalidParseContext, invalid_source_error_msg
  end
end
