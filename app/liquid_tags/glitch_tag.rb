class GlitchTag < LiquidTagBase
  attr_accessor :uri

  PARTIAL = "liquids/glitch".freeze
  ID_REGEXP = /\A[a-zA-Z0-9\-]{1,110}\z/
  TILDE_PREFIX_REGEXP = /\A~/
  OPTION_REGEXP = /(app|code|no-files|preview-first|no-attribution|file=\w(\.\w)?)/
  OPTIONS_TO_QUERY_PAIR = {
    "app" => %w[previewSize 100],
    "code" => %w[previewSize 0],
    "no-files" => %w[sidebarCollapsed true],
    "preview-first" => %w[previewFirst true],
    "no-attribution" => %w[attributionHidden true]
  }.freeze

  def initialize(_tag_name, id, _parse_context)
    super
    @query = parse_options(id)
    @id = parse_id(id)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        id: @id,
        query: @query
      },
    )
  end

  private

  def valid_id?(input)
    (input =~ ID_REGEXP)&.zero?
  end

  def parse_id(input)
    id = input.split.first
    id.sub!(TILDE_PREFIX_REGEXP, "")
    raise StandardError, I18n.t("liquid_tags.glitch_tag.invalid_glitch_id") unless valid_id?(id)

    id
  end

  def valid_option(option)
    option.match(OPTION_REGEXP)
  end

  def build_options(options)
    # Convert options to query param pairs
    params = options.filter_map { |option| OPTIONS_TO_QUERY_PAIR[option] }

    # Deal with the file option if present or use default
    file_option = options.detect { |option| option.start_with?("file=") }
    path = file_option ? (file_option.sub! "file=", "") : "index.html"
    params.push ["path", path]

    # Encode the resulting pairs as a query string
    URI.encode_www_form(params)
  end

  def parse_options(input)
    _, *options = input.split

    # 'app' and 'code' should cancel each other out
    options -= %w[app code] if (options & %w[app code]) == %w[app code]

    # Validation
    validated_options = options.filter_map { |option| valid_option(option) }
    unless options.empty? || !validated_options.empty?
      raise StandardError, I18n.t("liquid_tags.glitch_tag.invalid_options")
    end

    build_options(options)
  end
end

Liquid::Template.register_tag("glitch", GlitchTag)
