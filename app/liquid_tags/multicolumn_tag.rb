class MulticolumnTag < Liquid::Block
  PARTIAL = "liquids/multicolumn".freeze
  MULTICOLUMN_EXISTED = "multicolumn_existed".freeze

  def initialize(_tag_name, params, _parse_context)
    super
    @columns = parse_params(params)
  end

  def render(context)
    content = super
      .gsub(/<table\b/, '<div class="migdal-mc-table table-wrapper-paragraph"')
      .gsub(/<(tbody|thead|tfoot|tr|td|th)\b/, '<div class="migdal-mc-\1"')
      .gsub(%r{</(?:table|tbody|thead|tfoot|tr|td|th)\b}, "</div")
      .gsub(/\A\s*(?:<br>\s)+|(?:<br>\s)+\z/, "")

    no_js = !context[MULTICOLUMN_EXISTED]
    context[MULTICOLUMN_EXISTED] = true unless context[MULTICOLUMN_EXISTED]

    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        include_js: no_js,
        columns: @columns,
        content: content
      },
    )
  end

  def parse_params(params)
    count = ActionController::Base.helpers.strip_tags(params).split.first
    count = "2" unless count =~ /\A[0-9]\z/ && Integer(count, 10) > 1
    count
  end
end

Liquid::Template.register_tag("columns", MulticolumnTag)
