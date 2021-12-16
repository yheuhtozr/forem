class DartpadTag < LiquidTagBase
  PARTIAL = "liquids/dartpad".freeze
  ID_FORMAT = /\A(\h+) +(?:(dart|flutter|html|inline)\b)?/

  def initialize(_tag_name, params, _parse_context)
    super
    @id, @console = parse_params(params)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        id: @id,
        type: @console
      },
    )
  end

  def parse_params(params)
    m = ID_FORMAT.match params
    raise StandardError, I18n.t("migdal.liquid.dartpad.invalid") unless m[1]

    [m[1], (m[2].presence || "dart")]
  end
end

Liquid::Template.register_tag("dartpad", DartpadTag)
