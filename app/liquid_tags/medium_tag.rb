class MediumTag < LiquidTagBase
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  include InlineSvg::ActionView::Helpers
  attr_reader :response

  PARTIAL = "liquids/medium".freeze

  def initialize(_tag_name, url, _parse_context)
    super
    @response = parse_url_for_medium_article(url)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        response: @response
      },
    )
  end

  private

  def parse_url_for_medium_article(url)
    sanitized_article_url = ActionController::Base.helpers.strip_tags(url).strip

    MediumArticleRetrievalService.new(sanitized_article_url).call
  rescue StandardError
    raise_error
  end

  def raise_error
    raise StandardError, I18n.t("liquid_tags.medium_tag.invalid_link_url")
  end
end

Liquid::Template.register_tag("medium", MediumTag)
