class HiddenTag < Liquid::Block
  PARTIAL = "liquids/hidden".freeze

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

Liquid::Template.register_tag("hidden", HiddenTag)
