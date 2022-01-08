class CodepenTag < LiquidTagBase
  PARTIAL = "liquids/codepen".freeze
  REGISTRY_REGEXP =
    %r{\A(http|https)://(codepen\.io|codepen\.io/team)/[a-zA-Z0-9_\-]{1,30}/pen/([a-zA-Z0-9]{5,32})/{0,1}\z}

  def initialize(_tag_name, link, _parse_context)
    super
    @link = parse_link(link)
    @build_options = parse_options(link)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        link: @link,
        height: 600,
        build_options: @build_options
      },
    )
  end

  private

  def valid_option(option)
    option.match(/(default-tab=\w+(,\w+)?)/)
  end

  def parse_options(input)
    stripped_link = ActionController::Base.helpers.strip_tags(input)
    _, *options = stripped_link.split

    # Validation
    validated_options = options.filter_map { |option| valid_option(option) }
    unless options.empty? || !validated_options.empty?
      raise StandardError, I18n.t("liquid_tags.codepen_tag.invalid_options")
    end

    option = validated_options.join("&")

    option.presence || "default-tab=result"
  end

  def parse_link(link)
    stripped_link = ActionController::Base.helpers.strip_tags(link)
    the_link = stripped_link.split.first
    raise_error unless valid_link?(the_link)
    the_link.gsub("/pen/", "/embed/")
  end

  def valid_link?(link)
    link_no_space = link.delete(" ")
    (link_no_space =~ REGISTRY_REGEXP)&.zero?
  end

  def raise_error
    raise StandardError, I18n.t("liquid_tags.codepen_tag.invalid_codepen_url")
  end
end

Liquid::Template.register_tag("codepen", CodepenTag)

UnifiedEmbed.register(CodepenTag, regexp: CodepenTag::REGISTRY_REGEXP)
