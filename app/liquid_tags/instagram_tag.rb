class InstagramTag < LiquidTagBase
  PARTIAL = "liquids/instagram".freeze
  REGISTRY_REGEXP = %r{(?:https?://)?(?:www\.)?(?:instagram.com/p/)(?<video_id>[a-zA-Z0-9_-]{11})/?}
  VALID_ID_REGEXP = /\A(?<video_id>[a-zA-Z0-9_-]{11})\Z/
  REGEXP_OPTIONS = [REGISTRY_REGEXP, VALID_ID_REGEXP].freeze

  def initialize(_tag_name, id, _parse_context)
    super
    input   = CGI.unescape_html(strip_tags(id))
    @id     = parse_id_or_url(input)
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

  def parse_id(input)
    input_no_space = input.delete(" ")
    raise StandardError, I18n.t("liquid_tags.instagram_tag.invalid_instagram_id") unless valid_id?(input_no_space)

    match[:video_id]
  end
end

Liquid::Template.register_tag("instagram", InstagramTag)

UnifiedEmbed.register(InstagramTag, regexp: InstagramTag::REGISTRY_REGEXP)
