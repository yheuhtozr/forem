module Search
  class Comment
    ATTRIBUTES = [
      "COALESCE(articles.published, false) AS commentable_published",
      "COALESCE(articles.title, '') AS commentable_title",
      "comments.body_markdown",
      "comments.commentable_id",
      "comments.commentable_type",
      "comments.created_at",
      "comments.id AS id",
      "comments.public_reactions_count",
      "comments.score",
      "comments.user_id",
      "comments.body_markdown AS body_text", # PGroonga provisional dummy for now
    ].freeze
    private_constant :ATTRIBUTES

    DEFAULT_PER_PAGE = 60
    private_constant :DEFAULT_PER_PAGE

    DEFAULT_SORT_BY = "comments.score".freeze
    private_constant :DEFAULT_SORT_BY

    DEFAULT_SORT_DIRECTION = :desc
    private_constant :DEFAULT_SORT_DIRECTION

    MAX_PER_PAGE = 120 # to avoid querying too many items, we set a maximum amount for a page
    private_constant :MAX_PER_PAGE

    def self.search_documents(
      page: 0,
      per_page: DEFAULT_PER_PAGE,
      sort_by: DEFAULT_SORT_BY,
      sort_direction: DEFAULT_SORT_DIRECTION,
      term: nil
    )
      sort_by ||= DEFAULT_SORT_BY
      # The UI and serializer rename created_at (the actual DB column name) to
      # published_at
      sort_by = "comments.created_at" if sort_by == "published_at"

      sort_direction ||= DEFAULT_SORT_DIRECTION

      # NOTE: [@rhymes/atsmith813] we should eventually update the frontend
      # to start from page 1
      page = page.to_i + 1
      per_page = [(per_page || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min

      relation = ::Comment
        .includes(:user)
        .where(
          deleted: false,
          hidden_by_commentable_user: false,
          commentable_type: "Article",
        )
        .joins("join articles on articles.id = comments.commentable_id")
        .where("articles.published": true)

      attributes = ATTRIBUTES
      if term.present?
        relation = relation.search_comments(term)
        attributes = ATTRIBUTES.map do |a|
          if a.end_with? "body_text"
            # employ PGroonga's highlight for non-spacing locales
            ::Comment.sanitize_sql(["pgroonga_highlight_html(comments.body_markdown, ARRAY[?]) AS body_text", term])
          else
            a
          end
        end
      end

      relation = relation.select(*attributes).reorder("#{sort_by}": sort_direction)

      results = relation.page(page).per(per_page)

      serialize(results)
    end

    def self.serialize(results)
      Search::CommentSerializer
        .new(results, is_collection: true)
        .serializable_hash[:data]
        .pluck(:attributes)
    end
    private_class_method :serialize
  end
end
