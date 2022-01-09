module MarkdownProcessor
  class Parser
    include ApplicationHelper

    BAD_XSS_REGEX = [
      /src=["'](data|&)/i,
      %r{data:text/html[,;][\sa-z0-9]*}i,
    ].freeze

    # TODO: parse jamo, break Thai/Lao
    # rubocop:disable Layout/LineLength
    CHAR_AS_WORD = /
    (
      \p{Ideo}\p{VS}?[\u302A-\u302D\uA700-\uA707]? |
      \p{Bopo}[\u302A-\u302D]? |
      [\p{Hira}\p{Kana}][\u3099\u309A]? |
      [\u3033\u3034]\u3035 |
      [\p{Emoji_Presentation}\p{Hang}\p{IDSB}\p{IDST}\p{Laoo}\p{Thai}\p{Yiii}] |
      # compensation for missing scx function, and more
      [\u3001-\u303F\u3099-\u309C\u30A0\u30FB\u30FC\u3190-\u319F\u31C0-\u31EF\u3220-\u33FF\uA700-\uA707\uFE45\uFE46\uFF61-\uFF65\uFF70\uFF9E\uFF9F\u{1D360}-\u{1D371}\u{1F210}-\u{1F2FF}]
    )
    /x.freeze
    # rubocop:enable Layout/LineLength

    WORDS_READ_PER_MINUTE = 275.0
    ALLOWED_ATTRIBUTES = %w[href src alt].freeze

    def initialize(content, source: nil, user: nil)
      @content = content
      @source = source
      @user = user
    end

    def finalize(link_attributes: {})
      options = { hard_wrap: true, filter_html: false, link_attributes: link_attributes }
      renderer = Redcarpet::Render::HTMLRouge.new(options)
      markdown = Redcarpet::Markdown.new(renderer, Constants::Redcarpet::CONFIG)
      catch_xss_attempts(@content)
      code_tag_content = convert_code_tags_to_triple_backticks(@content)
      escaped_content = escape_liquid_tags_in_codeblock(code_tag_content)
      html = markdown.render(escaped_content)
      sanitized_content = sanitize_rendered_markdown(html)
      begin
        liquid_tag_options = { source: @source, user: @user }

        # NOTE: [@rhymes] liquid 5.0.0 does not support ActiveSupport::SafeBuffer,
        # a String substitute, hence we force the conversion before passing it to Liquid::Template.
        # See <https://github.com/Shopify/liquid/issues/1390>
        parsed_liquid = Liquid::Template.parse(sanitized_content.to_str, liquid_tag_options)

        html = markdown.render(parsed_liquid.render)
      rescue Liquid::SyntaxError => e
        html = e.message
      end

      parse_html(html)
    end

    def calculate_reading_time
      word_count = @content.split(/\W+/).count
      (word_count / WORDS_READ_PER_MINUTE).ceil
    end

    def word_char_count
      @content.split(CHAR_AS_WORD).each_with_index.reduce(0) do |r, (s, i)|
        r + (i.even? ? s.split(/(?u)\W+/u).size : 1)
      end
    end

    def evaluate_markdown
      return if @content.blank?

      renderer = Redcarpet::Render::HTMLRouge.new(hard_wrap: true, filter_html: false)
      markdown = Redcarpet::Markdown.new(renderer, Constants::Redcarpet::CONFIG)
      allowed_tags = %w[strong abbr aside em p h1 h2 h3 h4 h5 h6 i u b code pre
                        br ul ol li small sup sub img a span hr blockquote kbd]
      ActionController::Base.helpers.sanitize(markdown.render(@content),
                                              tags: allowed_tags,
                                              attributes: ALLOWED_ATTRIBUTES)
    end

    def evaluate_limited_markdown
      return if @content.blank?

      renderer = Redcarpet::Render::HTMLRouge.new(hard_wrap: true, filter_html: false)
      markdown = Redcarpet::Markdown.new(renderer, Constants::Redcarpet::CONFIG)
      allowed_tags = %w[strong i u b em p br code]
      ActionController::Base.helpers.sanitize(markdown.render(@content),
                                              tags: allowed_tags,
                                              attributes: ALLOWED_ATTRIBUTES)
    end

    def evaluate_inline_limited_markdown
      return if @content.blank?

      renderer = Redcarpet::Render::HTMLRouge.new(hard_wrap: true, filter_html: false)
      markdown = Redcarpet::Markdown.new(renderer, Constants::Redcarpet::CONFIG)
      allowed_tags = %w[strong i u b em code]
      ActionController::Base.helpers.sanitize(markdown.render(@content),
                                              tags: allowed_tags,
                                              attributes: ALLOWED_ATTRIBUTES)
    end

    def evaluate_listings_markdown
      return if @content.blank?

      renderer = Redcarpet::Render::HTMLRouge.new(hard_wrap: true, filter_html: false)
      markdown = Redcarpet::Markdown.new(renderer, Constants::Redcarpet::CONFIG)
      allowed_tags = %w[strong abbr aside em p h4 h5 h6 i u b code pre
                        br ul ol li small sup sub a span hr blockquote kbd]
      ActionController::Base.helpers.sanitize(markdown.render(@content),
                                              tags: allowed_tags,
                                              attributes: ALLOWED_ATTRIBUTES)
    end

    def tags_used
      return [] if @content.blank?

      cleaned_parsed = escape_liquid_tags_in_codeblock(@content)
      tags = []
      liquid_tag_options = { source: @source, user: @user }
      Liquid::Template.parse(cleaned_parsed, liquid_tag_options).root.nodelist.each do |node|
        tags << node.class if node.class.superclass.to_s == LiquidTagBase.to_s
      end
      tags.uniq
    rescue Liquid::SyntaxError
      []
    end

    def catch_xss_attempts(markdown)
      return unless markdown.match?(Regexp.union(BAD_XSS_REGEX))

      raise ArgumentError, I18n.t("services.markdown_processor.parser.invalid_markdown_detected")
    end

    def escape_liquid_tags_in_codeblock(content)
      # Escape codeblocks, code spans, and inline code
      content.gsub(/[[:space:]]*~{3}.*?~{3}|[[:space:]]*`{3}.*?`{3}|`{2}.+?`{2}|`{1}.+?`{1}/m) do |codeblock|
        codeblock.gsub!("{% endraw %}", "{----% endraw %----}")
        codeblock.gsub!("{% raw %}", "{----% raw %----}")
        if codeblock.match?(/[[:space:]]*`{3}/)
          "\n{% raw %}\n#{codeblock}\n{% endraw %}\n"
        else
          "{% raw %}#{codeblock}{% endraw %}"
        end
      end
    end

    def convert_code_tags_to_triple_backticks(content)
      # return content if there is not a <code> tag
      return content unless /^<code>$/.match?(content)

      # return content if there is a <pre> and <code> tag
      return content if /<code>/.match?(content) && /<pre>/.match?(content)

      # Convert all multiline code tags to triple backticks
      content.gsub(%r{^</?code>$}, "\n```\n")
    end

    private

    def parse_html(html)
      return html if html.blank?

      Html::Parser
        .new(html)
        .remove_nested_linebreak_in_list
        .prefix_all_images
        .wrap_all_images_in_links
        .add_control_class_to_codeblock
        .add_control_panel_to_codeblock
        .add_fullscreen_button_to_panel
        .wrap_all_tables
        .remove_empty_paragraphs
        .escape_colon_emojis_in_codeblock
        .unescape_raw_tag_in_codeblocks
        .wrap_all_figures_with_tags
        .wrap_mentions_with_links
        .html
    end
  end
end
