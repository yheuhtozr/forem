class SocialPreviewsController < ApplicationController
  # No authorization required for entirely public controller

  PNG_CSS = "body { transform: scale(0.3); } .preview-div-wrapper { overflow: unset; margin: 5vw; }".freeze

  def article
    @article = Article.find(params[:id])
    @lang = @article.base_lang

    respond_to do |format|
      template = "social_previews/articles/migdal_ogp"
      format.html do
        render template, layout: false
      end
      format.png do
        html = render_to_string template, formats: :html, layout: false
        redirect_to OgpGeneration.instance.url(html, params[:id]), status: :found
      end
    end
  end

  private

  def set_respond(template = nil)
    respond_to do |format|
      format.html do
        render template, layout: false
      end
      format.png do
        html = render_to_string(template, formats: :html, layout: false)
        url = HtmlCssToImage.fetch_url(html: html, css: PNG_CSS,
                                       google_fonts: I18n.t("social_previews_controller.fonts"))
        redirect_to url, allow_other_host: true, status: :found
      end
    end
  end
end
