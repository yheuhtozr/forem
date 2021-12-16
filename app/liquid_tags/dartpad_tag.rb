class DartpadTag < LiquidTagBase
  PARTIAL = "liquids/dartpad".freeze
  ID_FORMAT = %r{\A(\h+) +(?:(dart|flutter|html|inline)\b)?(?: +(\w[\w/= ]*))?}
  OPTIONS = %w[gh_owner gh_path gh_ref gh_repo null_safety run sample_channel sample_id split theme].freeze

  def initialize(_tag_name, params, _parse_context)
    super
    @id, @console, @options = parse_params(params)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        id: @id,
        type: @console,
        options: @options
      },
    )
  end

  def parse_params(params)
    m = ID_FORMAT.match params
    raise StandardError, I18n.t("migdal.liquid.dartpad.invalid") unless m[1]

    options = m[3] ? m[3].split.map { |pair| pair.split("=")[0..1] }.to_h.select { |k, _| OPTIONS.include? k }.compact : {} # rubocop:disable Layout/LineLength
    [m[1], (m[2].presence || "dart"), options]
  end
end

Liquid::Template.register_tag("dartpad", DartpadTag)
