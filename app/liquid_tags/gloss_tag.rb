class GlossTag < Liquid::Block
  PARTIAL = "liquids/gloss".freeze

  def initialize(_tag_name, params, _parse_context)
    super
    @has_orig = params.match?(/\borig\b/)
    @has_free = params.match?(/\bfree\b/)
  end

  def render(_context)
    inner = super.gsub(/\A\s*(?:<br>\s)+|(?:<br>\s)+\z/, "").split("<br>").map(&:strip)
    orig = @has_orig ? inner.shift : nil
    free = @has_free ? inner.pop : nil

    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        lines: inner,
        orig: orig,
        free: free
      },
    )
  end
end

Liquid::Template.register_tag("gloss", GlossTag)
