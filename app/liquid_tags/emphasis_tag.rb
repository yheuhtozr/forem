class EmphasisTag < Liquid::Block
  PARTIAL = "liquids/emphasis".freeze

  # def initialize(_tag_name, _markup, parse_context)
  #   super
  # end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        content: super
      },
    )
  end
end

Liquid::Template.register_tag("te", EmphasisTag)
