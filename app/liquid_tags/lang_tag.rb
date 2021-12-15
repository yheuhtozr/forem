class LangTag < Liquid::Block
  PARTIAL = "liquids/lang".freeze
  TAGFORMAT = /\A(?:
    (?:\{ietf\})?(?<ietf>[a-z]{1,8}(?:-[a-z0-9]{1,8})*) |
    (?:\{cla3\})?(?<cla3>(?<c_dia>[a-z]{2}|~|\*)_(?<c_lng>[a-z]{2})_(?<c_fml>[a-z]{3}|~)_(?<c_aut>[a-z]{3})) |
    (?:\{[a-z]{3}[a-z0-9]\})?(?<unkn>\S+)
  )/x

  def initialize(tag_name, langtag, _parse_context)
    super
    @name = tag_name == "ln" ? "span" : "div"
    @lang = parse_lang(langtag)
  end

  def render(_context)
    content = super.sub(/\A\s*(?:<br>\s)+|(?:<br>\s)+\z/, "").html_safe # rubocop:disable Rails/OutputSafety

    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        name: @name,
        lang: @lang,
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
