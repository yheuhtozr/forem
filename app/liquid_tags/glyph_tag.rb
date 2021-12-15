class GlyphTag < LiquidTagBase
  PARTIAL = "liquids/glyph".freeze
  # valid values for vertical-align
  ALLOWED = /\A(?:
    baseline|bottom|inherit|initial|middle|revert|sub|super|text-bottom|text-top|top|unset|
    (?:(?:[+-]?\d*\.?\d+)(?:%|Q|ch|em|ex|rem|vh|vmax|vmin|vw|cm|in|mm|pc|pt|px)?)
  )\z/x

  def initialize(_tag_name, params, _parse_context)
    super
    vars = strip_tags(params)
    src, name, align, * = vars.split(" ", 4)
    @src = src
    @name = name.presence
    @align = ALLOWED.match(align) ? align : "sub"
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        align: @align,
        name: @name,
        src: @src
      },
    )
  end
end

Liquid::Template.register_tag("glyph", GlyphTag)
