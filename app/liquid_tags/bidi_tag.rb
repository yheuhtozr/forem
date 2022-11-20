class BidiTag < Liquid::Block
  PARTIAL = "liquids/bidi".freeze

  def initialize(tag_name, _markup, _parse_context)
    super
    @name = tag_name.size == 2 ? "bdo" : "div"
    @dir = tag_name.start_with?("r") ? "rtl" : "ltr"
  end

  def render(_context)
    content = super.gsub(/\A\s*(?:<br>\s)+|(?:<br>\s)+\z/, "")

    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        name: @name,
        dir: @dir,
        content: content
      },
    )
  end
end

Liquid::Template.register_tag("rl", BidiTag)
Liquid::Template.register_tag("lr", BidiTag)
Liquid::Template.register_tag("rtl", BidiTag)
Liquid::Template.register_tag("ltr", BidiTag)
