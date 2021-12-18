class DialogueTag < Liquid::Block
  PARTIAL = "liquids/dialogue".freeze

  def initialize(_tag_name, params, _parse_context)
    super
    @side, @back, @border, @icon, @name = parse_params(params)
  end

  def render(_context)
    content = super.gsub(/\A\s*(?:<br>\s)+|(?:<br>\s)+\z/, "")

    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        icon: @icon,
        name: @name,
        side: @side,
        back: @back,
        border: @border,
        content: content
      },
    )
  end

  def parse_params(params)
    first, image, rest = ActionController::Base.helpers.strip_tags(params).strip.split(" ", 3)
    side, back, border, * = first.split(":")
    which = %w[left right].include?(side) ? side : "left"

    [which, back, border, image, rest]
  end
end

Liquid::Template.register_tag("dialogue", DialogueTag)
