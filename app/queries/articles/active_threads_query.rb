module Articles
  class ActiveThreadsQuery
    MINIMUM_SCORE = -4

    def self.default_options
      {
        tags: I18n.t("queries.articles.active_threads_query.default_tags").split(","),
        time_ago: nil,
        count: 10
      }.with_indifferent_access
    end

    def self.call(relation: Article.published, **options)
      options = default_options.merge(options)
      tags, time_ago, count = options.values_at(:tags, :time_ago, :count)

      relation = relation.limit(count)
      relation = tags.size == 1 ? relation.cached_tagged_with(tags.first) : relation.tagged_with(tags)
      relation = if time_ago == "latest"
                   relation = relation.where(score: MINIMUM_SCORE..).presence || relation
                   relation.order(published_at: :desc)
                 elsif time_ago
                   relation = relation.where(published_at: time_ago.., score: MINIMUM_SCORE..).presence || relation
                   relation.order(comments_count: :desc)
                 else
                   relation = relation.where(published_at: 3.days.ago.., score: MINIMUM_SCORE..).presence || relation
                   relation.order("last_comment_at DESC NULLS LAST")
                 end
      relation.pluck(:path, :title, :comments_count, :created_at)
    end
  end
end
