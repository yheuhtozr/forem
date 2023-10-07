class RubyTag < LiquidTagBase
  PARTIAL = "liquids/ruby".freeze

  def initialize(_tag_name, params, _parse_context)
    super
    @pairs = parse_params(params)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        annotations: @pairs
      },
    )
  end

  def parse_params(params)
    before, sep, after = ActionController::Base.helpers.strip_tags(params).strip.rpartition(/\s+?\|\|\s+?/)

    if sep.blank?
      base, *tops = after.split
      bases = tops.size <= 1 ? [base] : base.chars
    else
      bases = before.split("|").map(&:strip)
      tops = after.split("|").map(&:strip)
    end
    paired = bases.zip tops
    paired[-1][1] = tops[(paired.size - 1)...].join if tops.size > paired.size

    paired
  end
end

Liquid::Template.register_tag("r", RubyTag)
