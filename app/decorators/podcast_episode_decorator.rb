class PodcastEpisodeDecorator < ApplicationDecorator
  def comments_to_show_count
    cached_tag_list_array.include?(I18n.t("decorators.podcast_episode_decorator.discuss")) ? 75 : 25
  end

  # this method exists because podcast episodes are "commentables"
  # and in some parts of the code we assume they have this method,
  # but podcast episodes don't have a cached_tag_list like articles do
  def cached_tag_list_array
    tag_list
  end

  def readable_publish_date
    return "" unless published_at

    if published_at.year == Time.current.year
      published_at.strftime R18n.t.date.readable.no_year
    else
      published_at.strftime R18n.t.date.readable.with_year
    end
  end

  def published_timestamp
    return "" unless published_at

    published_at.utc.iso8601
  end

  def mobile_player_metadata
    {
      podcastName: podcast.title,
      episodeName: title,
      podcastImageUrl: Images::Optimizer.call(podcast.image_url, width: 600, quality: 80)
    }
  end

  def published_at_int
    published_at.to_i
  end
end
