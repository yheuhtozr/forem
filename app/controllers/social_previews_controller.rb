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

  def user
    @user = User.find(params[:id])
    @tag_badges = Badge.where(id: @user.badge_achievements.select(:badge_id))
    set_respond
  end

  def listing
    @listing = Listing.find(params[:id]).decorate
    set_respond
  end

  def organization
    @user = Organization.find(params[:id])
    @tag_badges = [] # Orgs don't have badges, but they could!
    set_respond "user"
  end

  def tag
    @tag = Tag.find(params[:id])
    @compare_hex = Color::CompareHex.new([@tag.bg_color_hex || "#000000", @tag.text_color_hex || "#ffffff"])

    set_respond
  end

  def comment
    @comment = Comment.find(params[:id])

    badge_ids = Tag.where(name: @comment.commentable&.decorate&.cached_tag_list_array).pluck(:badge_id)
    @tag_badges = Badge.where(id: badge_ids)

    set_respond
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
