class ArticleDecorator < ApplicationDecorator
  LONG_MARKDOWN_THRESHOLD = 900

  def current_state_path
    published ? "/#{username}/#{slug}" : "/#{username}/#{slug}?preview=#{password}"
  end

  def processed_canonical_url
    if canonical_url.present?
      canonical_url.to_s.strip
    else
      url
    end
  end

  def comments_to_show_count
    cached_tag_list_array.include?(I18n.t("decorators.article_decorator.discuss")) ? 75 : 25
  end

  def cached_tag_list_array
    (cached_tag_list || "").split(", ")
  end

  def url
    URL.url(path)
  end

  def title_length_classification
    if title.size > 105
      "longest"
    elsif title.size > 80
      "longer"
    elsif title.size > 60
      "long"
    elsif title.size > 22
      "medium"
    else
      "short"
    end
  end

  def internal_utm_params(place = "additional_box")
    org_slug = organization&.slug

    campaign = if boosted_additional_articles
                 "#{org_slug}_boosted"
               else
                 "regular"
               end

    "?utm_source=#{place}&utm_medium=internal&utm_campaign=#{campaign}&booster_org=#{org_slug}"
  end

  def published_at_int
    published_at.to_i
  end

  def title_with_query_preamble(user_signed_in)
    if search_optimized_title_preamble.present? && !user_signed_in
      "#{search_optimized_title_preamble}: #{title}"
    else
      title
    end
  end

  def description_and_tags
    return search_optimized_description_replacement if search_optimized_description_replacement.present?

    modified_description = description.strip
    modified_description += "." unless description.end_with?(".")
    return modified_description if cached_tag_list.blank?

    modified_description + I18n.t("decorators.article_decorator.tagged_with", cached_tag_list: cached_tag_list)
  end

  def video_metadata
    {
      id: id,
      video_code: video_code,
      video_source_url: video_source_url,
      video_thumbnail_url: cloudinary_video_url,
      video_closed_caption_track_url: video_closed_caption_track_url
    }
  end

  def has_recent_comment_activity?(timeframe = 1.week.ago)
    return false if last_comment_at.blank?

    last_comment_at > timeframe
  end

  def long_markdown?
    body_markdown.present? && body_markdown.size > LONG_MARKDOWN_THRESHOLD
  end

  def co_authors
    User.select(:name, :username).where(id: co_author_ids).order(created_at: :asc)
  end

  def co_author_name_and_path
    co_authors.map do |user|
      "<b><a href=\"#{user.path}\">#{user.name}</a></b>"
    end.to_sentence
  end

  # Used in determining when to bust additional routes for an Article's comments
  def discussion?
    cached_tag_list_array.include?(I18n.t("decorators.article_decorator.discuss")) &&
      featured_number.to_i > 35.hours.ago.to_i
  end
end
