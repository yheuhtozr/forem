class BlogcastTag < LiquidTagBase
  PARTIAL = "liquids/blogcast".freeze
  def initialize(_tag_name, id, _parse_context)
    super
    @id = parse_id(id)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        id: @id
      },
    )
  end

  private

  def parse_id_or_url(input)
    match = pattern_match_for(input, REGEXP_OPTIONS)
    raise StandardError, I18n.t("liquid_tags.blogcast_tag.invalid_blogcast_id") unless match

  def valid_id?(id)
    (id =~ /\A\d{1,9}\Z/i)&.zero?
  end
end

Liquid::Template.register_tag("blogcast", BlogcastTag)
