class LangTag < Liquid::Block
  PARTIAL = "liquids/lang".freeze
  TAGFORMAT = /\A(?:
    (?:\{ietf\})?(?<ietf>[a-z]{1,8}(?:-[a-z0-9]{1,8})*) |
    (?:\{cla3\})?(?<cla3>(?<c_dia>[a-z]{2}|~|\*)_(?<c_lng>[a-z]{2})_(?<c_fml>[a-z]{3}|~)_(?<c_aut>[a-z]{3})) |
    (?:\{[a-z]{3}[a-z0-9]\})?(?<unkn>\S+)
  )/x

  def initialize(tag_name, params, _parse_context)
    super
    @name = tag_name == "ln" ? "span" : "div"
    langtag, dir, * = params.strip.split(" ", 3)
    @lang = parse_lang(langtag)
    @dir = %w[ltr rtl].include?(dir) ? %( dir="#{dir}") : ""
  end

  def render(_context)
    content = super.gsub(/\A\s*(?:<br>\s)+|(?:<br>\s)+\z/, "")

    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        name: @name,
        lang: @lang,
        dir: @dir,
        content: content
      },
    )
  end

  def parse_lang(langtag)
    m = TAGFORMAT.match langtag
    if m[:ietf]
      m[:ietf]
    elsif m[:cla3]
      "x-v3-#{m[:c_aut]}#{m[:c_fml] == '~' ? '0' : m[:c_fml]}#{m[:c_lng]}#{'-' << m[:c_dia] if m[:c_dia] && m[:c_dia].len > 1}" # rubocop:disable Layout/LineLength
    else
      m[:unkn]
    end
  end
end

Liquid::Template.register_tag("ln", LangTag)
Liquid::Template.register_tag("lang", LangTag)
