class Article < ApplicationRecord
  include CloudinaryHelper
  include ActionView::Helpers
  include Reactable
  include Taggable
  include UserSubscriptionSourceable
  include PgSearch::Model
  include Sluggifiable
  include Localizable

  acts_as_taggable_on :tags
  resourcify

  include StringAttributeCleaner.nullify_blanks_for(:canonical_url, on: :before_save)
  DEFAULT_FEED_PAGINATION_WINDOW_SIZE = 50

  # When we cache an entity, either {User} or {Organization}, these are the names of the attributes
  # we cache.
  #
  # @note I would prefer that this constant were in the {Article::CachedEntity} namespace, but it
  #       didn't work out well.  Further, since Organization doesn't really know about
  #       Articles::CachedEntity, I'd rather it not "peek" into a class for which it has no
  #       knowledge.
  #
  # @note [@jeremyf] I have added the profile_image attribute, even though that's not one of the
  #       Articles::CachedEntity attributes.  This is necessary to detect the change.
  #
  # @see Articles::CachedEntity caching strategy for entity attributes
  ATTRIBUTES_CACHED_FOR_RELATED_ENTITY = %i[name profile_image profile_image_url slug username].freeze

  # admin_update was added as a hack to bypass published_at validation when admin is updating
  # TODO: [@lightalloy] remove published_at validation from the model and
  # move it to the services where the create/update takes place to avoid using hacks
  attr_accessor :publish_under_org, :admin_update
  attr_writer :series

  delegate :name, to: :user, prefix: true
  delegate :username, to: :user, prefix: true

  # touch: true was removed because when an article is updated, the associated collection
  # is touched along with all its articles(including this one). This causes eventually a deadlock.
  belongs_to :collection, optional: true

  belongs_to :organization, optional: true
  belongs_to :user

  counter_culture :user
  counter_culture :organization

  # The date that we began limiting the number of user mentions in an article.
  MAX_USER_MENTION_LIVE_AT = Time.utc(2021, 4, 7).freeze
  # all BIDI control marks (a part of them are expected to be removed during #normalize_title, but still)
  BIDI_CONTROL_CHARACTERS = /[\u061C\u200E\u200F\u202a-\u202e\u2066-\u2069]/

  MAX_TAG_LIST_SIZE = 4

  # Filter out anything that isn't a word, space, punctuation mark,
  # recognized emoji, and other auxiliary marks.
  # See: https://github.com/forem/forem/pull/16787#issuecomment-1062044359
  #
  # NOTE: try not to use hyphen (- U+002D) in comments inside regex,
  # otherwise it may break parser randomly.
  # Use underscore or Unicode hyphen (‐ U+2010) instead.
  # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
  TITLE_CHARACTERS_ALLOWED = /[^
    [:word:]
    [:space:]
    [:punct:]
    \p{Sc}        # All currency symbols
    \u00a9        # Copyright symbol
    \u00ae        # Registered trademark symbol
    \u061c        # BIDI: Arabic letter mark
    \u180e        # Mongolian vowel separator
    \u200c        # Zero‐width non‐joiner, for complex scripts
    \u200d        # Zero-width joiner, for multipart emojis such as family
    \u200e-\u200f # BIDI: LTR and RTL mark (standalone)
    \u202c-\u202e # BIDI: POP, LTR, and RTL override
    \u2066-\u2069 # BIDI: LTR, RTL, FSI, and POP isolate
    \u20e3        # Combining enclosing keycap
    \u2122        # Trademark symbol
    \u2139        # Information symbol
    \u2194-\u2199 # Arrow symbols
    \u21a9-\u21aa # More arrows
    \u231a        # Watch emoji
    \u231b        # Hourglass emoji
    \u2328        # Keyboard emoji
    \u23cf        # Eject symbol
    \u23e9-\u23f3 # Various VCR‐actions emoji and clocks
    \u23f8-\u23fa # More VCR emoji
    \u24c2        # Blue circle with a white M in it
    \u25aa        # Black box
    \u25ab        # White box
    \u25b6        # VCR‐style play emoji
    \u25c0        # VCR‐style play backwards emoji
    \u25fb-\u25fe # More black and white squares
    \u2600-\u273f # Weather, zodiac, coffee, hazmat, cards, music, other misc emoji
    \u2744        # Snowflake emoji
    \u2747        # Sparkle emoji
    \u274c        # Cross mark
    \u274e        # Cross mark box
    \u2753-\u2755 # Big red and white ? emoji, big white ! emoji
    \u2757        # Big red ! emoji
    \u2763-\u2764 # Heart ! and heart emoji
    \u2795-\u2797 # Math operator emoji
    \u27a1        # Right arrow
    \u27b0        # One loop
    \u27bf        # Two loops
    \u2934        # Curved arrow pointing up to the right
    \u2935        # Curved arrow pointing down to the right
    \u2b00-\u2bff # More arrows, geometric shapes
    \u3030        # Squiggly line
    \u303d        # Either a line chart plummeting or the letter M, not sure
    \u3297        # Circled Ideograph Congratulation
    \u3299        # Circled Ideograph Secret
    \u{1f000}-\u{1ffff} # More common emoji
  ]+/m
  # rubocop:enable Lint/DuplicateRegexpCharacterClassElement

  def self.unique_url_error
    I18n.t("models.article.unique_url", email: ForemInstance.contact_email)
  end

  has_one :discussion_lock, dependent: :delete

  has_many :mentions, as: :mentionable, inverse_of: :mentionable, dependent: :delete_all
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :nullify
  has_many :context_notifications, as: :context, inverse_of: :context, dependent: :delete_all
  has_many :context_notifications_published, -> { where(context_notifications: { action: "Published" }) },
           as: :context, inverse_of: :context, class_name: "ContextNotification"
  has_many :notification_subscriptions, as: :notifiable, inverse_of: :notifiable, dependent: :delete_all
  has_many :notifications, as: :notifiable, inverse_of: :notifiable, dependent: :delete_all
  has_many :page_views, dependent: :delete_all
  # `dependent: :destroy` because in Poll we cascade the deletes of
  #     the poll votes, options, and skips.
  has_many :polls, dependent: :destroy
  has_many :profile_pins, as: :pinnable, inverse_of: :pinnable, dependent: :delete_all
  # `dependent: :destroy` because in RatingVote we're relying on
  #     counter_culture to do some additional tallies
  has_many :rating_votes, dependent: :destroy
  has_many :top_comments,
           lambda {
             where(comments: { score: 11.. }, ancestry: nil, hidden_by_commentable_user: false, deleted: false)
               .order("comments.score" => :desc)
           },
           as: :commentable,
           inverse_of: :commentable,
           class_name: "Comment"

  validates :base_lang, format: {
    with: /\A[0-9A-Za-z]{1,8}(?:-[0-9A-Za-z]{1,8})*\z/,
    message: proc { I18n.t("common.invalid_langtag") }
  }, allow_blank: true
  validates :body_markdown, bytesize: {
    maximum: 800.kilobytes,
    too_long: proc { I18n.t("models.article.is_too_long") }
  }
  validates :body_markdown, length: { minimum: 0, allow_nil: false }
  validates :body_markdown, uniqueness: { scope: %i[user_id title] }
  validates :cached_tag_list, length: { maximum: 126 }
  validates :canonical_url,
            uniqueness: { allow_nil: true, scope: :published, message: unique_url_error },
            if: :published?
  validates :canonical_url, url: { allow_blank: true, no_local: true, schemes: %w[https http] }
  validates :comments_count, presence: true
  validates :feed_source_url,
            uniqueness: { allow_nil: true, scope: :published, message: unique_url_error },
            if: :published?
  validates :feed_source_url, url: { allow_blank: true, no_local: true, schemes: %w[https http] }
  validates :main_image, url: { allow_blank: true, schemes: %w[https http] }
  validates :main_image_background_hex_color, format: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/
  validates :positive_reactions_count, presence: true
  validates :previous_public_reactions_count, presence: true
  validates :public_reactions_count, presence: true
  validates :rating_votes_count, presence: true
  validates :reactions_count, presence: true
  validates :slug, presence: { if: :published? }
  validates :slug, uniqueness: { scope: :user_id }
  validates :title, presence: true, length: { maximum: 128 }
  validates :user_subscriptions_count, presence: true
  validates :video, url: { allow_blank: true, schemes: %w[https http] }
  validates :video_closed_caption_track_url, url: { allow_blank: true, schemes: ["https"] }
  validates :video_source_url, url: { allow_blank: true, schemes: ["https"] }
  validates :video_source_url, url: { allow_blank: true, schemes: ["https"] }
  validates :video_state, inclusion: { in: %w[PROGRESSING COMPLETED] }, allow_nil: true
  validates :video_thumbnail_url, url: { allow_blank: true, schemes: %w[https http] }
  validate :future_or_current_published_at, on: :create
  validate :correct_published_at?, on: :update, unless: :admin_update

  validate :canonical_url_must_not_have_spaces
  validate :validate_collection_permission
  validate :validate_tag
  validate :validate_video
  validate :user_mentions_in_markdown
  validate :validate_co_authors, unless: -> { co_author_ids.blank? }
  validate :validate_co_authors_must_not_be_the_same, unless: -> { co_author_ids.blank? }
  validate :validate_co_authors_exist, unless: -> { co_author_ids.blank? }

  before_validation :evaluate_markdown, :create_slug, :set_published_date
  before_validation :normalize_title
  before_validation :remove_prohibited_unicode_characters
  before_save :set_cached_entities
  before_save :set_all_dates

  before_save :calculate_base_scores
  before_save :fetch_video_duration
  before_save :set_caches
  before_create :create_password
  before_destroy :before_destroy_actions, prepend: true

  after_save :create_conditional_autovomits
  after_save :bust_cache
  after_save :collection_cleanup
  after_save :eponymous_translation_group

  after_update_commit :update_notifications, if: proc { |article|
                                                   article.notifications.any? && !article.saved_changes.empty?
                                                 }
  after_update_commit :update_notification_subscriptions, if: proc { |article|
    article.saved_change_to_user_id?
  }

  after_commit :async_score_calc, :touch_collection, :enrich_image_attributes, :record_field_test_event,
               on: %i[create update]

  # @todo Enforce the serialization class (e.g., Articles::CachedEntity)
  # @see https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html#method-i-serialize
  serialize :cached_user

  # @todo Enforce the serialization class (e.g., Articles::CachedEntity)
  # @see https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html#method-i-serialize
  serialize :cached_organization

  scope :search_articles, lambda { |query|
    where(
      "ARRAY[title, cached_tag_list, body_markdown, cached_user_name, cached_user_username]
      &@~ (?, ARRAY[10, 4, 2, 1, 1, 1], 'index_articles_full_text')::pgroonga_full_text_search_condition",
      query,
    )
  }

  # [@jgaskins] We use an index on `published`, but since it's a boolean value
  #   the Postgres query planner often skips it due to lack of diversity of the
  #   data in the column. However, since `published_at` is a *very* diverse
  #   column and can scope down the result set significantly, the query planner
  #   can make heavy use of it.
  scope :published, lambda {
    where(published: true)
      .where("published_at <= ?", Time.current)
  }
  scope :unpublished, -> { where(published: false) }

  scope :not_authored_by, ->(user_id) { where.not(user_id: user_id) }

  # [@jeremyf] For approved articles is there always an assumption of
  #            published?  Regardless, the scope helps us deal with
  #            that in the future.
  scope :approved, -> { where(approved: true) }

  scope :admin_published_with, lambda { |tag_name|
    published
      .where(user_id: User.with_role(:super_admin)
                          .union(User.with_role(:admin))
                          .union(id: [Settings::Community.staff_user_id,
                                      Settings::General.mascot_user_id].compact)
                          .select(:id)).order(published_at: :desc).tagged_with(tag_name)
  }

  scope :user_published_with, lambda { |user_id, tag_name|
    published
      .where(user_id: user_id)
      .order(published_at: :desc)
      .tagged_with(tag_name)
  }

  scope :active_help, lambda {
    stories = published.cached_tagged_with("help").order(created_at: :desc)

    stories.where(published_at: 12.hours.ago.., comments_count: ..5, score: -3..).presence || stories
  }

  scope :limited_column_select, lambda {
    select(:path, :title, :id, :published,
           :comments_count, :public_reactions_count, :cached_tag_list,
           :main_image, :main_image_background_hex_color, :updated_at, :slug,
           :video, :user_id, :organization_id, :video_source_url, :video_code,
           :video_thumbnail_url, :video_closed_caption_track_url,
           :experience_level_rating, :experience_level_rating_distribution, :cached_user, :cached_organization,
           :published_at, :crossposted_at, :boost_states, :description, :reading_time, :video_duration_in_seconds,
           :last_comment_at, :base_lang)
  }

  scope :limited_columns_internal_select, lambda {
    select(:path, :title, :id, :featured, :approved, :published,
           :comments_count, :public_reactions_count, :cached_tag_list,
           :main_image, :main_image_background_hex_color, :updated_at,
           :video, :user_id, :organization_id, :video_source_url, :video_code,
           :video_thumbnail_url, :video_closed_caption_track_url, :social_image,
           :published_from_feed, :crossposted_at, :published_at, :created_at,
           :body_markdown, :email_digest_eligible, :processed_html, :co_author_ids, :base_lang)
  }

  scope :sorting, lambda { |value|
    value ||= "creation-desc"
    kind, dir = value.split("-")

    dir = "desc" unless %w[asc desc].include?(dir)

    case kind
    when "creation"
      order(created_at: dir)
    when "views"
      order(page_views_count: dir)
    when "reactions"
      order(public_reactions_count: dir)
    when "comments"
      order(comments_count: dir)
    when "published"
      # NOTE: For recently published, we further filter to only published posts
      order(published_at: dir).published
    else
      order(created_at: dir)
    end
  }

  # @note This includes the `featured` scope, which may or may not be
  #       something we expose going forward.  However, it was
  #       something used in two of the three queries we had that
  #       included the where `score > Settings::UserExperience.home_feed_minimum_score`
  scope :with_at_least_home_feed_minimum_score, lambda {
    featured.or(
      where(score: Settings::UserExperience.home_feed_minimum_score..),
    )
  }

  scope :featured, -> { where(featured: true) }

  scope :feed, lambda {
                 published.includes(:taggings)
                   .select(
                     :id, :published_at, :processed_html, :user_id, :organization_id, :title, :path, :cached_tag_list,
                     :base_lang
                   )
               }

  scope :with_video, lambda {
                       published
                         .where.not(video: [nil, ""])
                         .where.not(video_thumbnail_url: [nil, ""])
                         .where("score > ?", -4)
                     }

  scope :eager_load_serialized_data, -> { includes(:user, :organization, :tags) }

  def self.seo_boostable(tag = nil, time_ago = 18.days.ago)
    # Time ago sometimes returns this phrase instead of a date
    time_ago = 5.days.ago if time_ago == "latest"

    # Time ago sometimes is given as nil and should then be the default. I know, sloppy.
    time_ago = 75.days.ago if time_ago.nil?

    relation = Article.published
      .order(organic_page_views_past_month_count: :desc)
      .where("score > ?", 8)
      .where("published_at > ?", time_ago)
      .limit(20)

    fields = %i[path title comments_count created_at]
    if tag
      relation.cached_tagged_with(tag).pluck(*fields)
    else
      relation.pluck(*fields)
    end
  end

  def self.search_optimized(tag = nil)
    relation = Article.published
      .order(updated_at: :desc)
      .where.not(search_optimized_title_preamble: nil)
      .limit(20)

    fields = %i[path search_optimized_title_preamble comments_count created_at]
    if tag
      relation.cached_tagged_with(tag).pluck(*fields)
    else
      relation.pluck(*fields)
    end
  end

  def scheduled?
    published_at? && published_at.future?
  end

  def search_id
    "article_#{id}"
  end

  def processed_description
    if body_text.present?
      body_text
        .truncate(104, separator: /[\p{P}\p{Z}\p{Ideo}\p{Hang}]/)
        .tr("\n", " ")
        .strip
    else
      I18n.t("models.article.a_post_by", user_name: user.name)
    end
  end

  def body_text
    ActionView::Base.full_sanitizer.sanitize(processed_html)[0..7000]
  end

  def touch_by_reaction
    async_score_calc
  end

  def comments_blob
    return "" if comments_count.zero?

    ActionView::Base.full_sanitizer.sanitize(comments.pluck(:body_markdown).join(" "))[0..2200]
  end

  def username
    return organization.slug if organization

    user.username
  end

  def current_state_path
    published && !scheduled? ? "/#{username}/#{slug}" : "/#{username}/#{slug}?preview=#{password}"
  end

  def has_frontmatter?
    if FeatureFlag.enabled?(:consistent_rendering, FeatureFlag::Actor[user])
      processed_content.has_front_matter?
    else
      original_has_frontmatter?
    end
  end

  def original_has_frontmatter?
    fixed_body_markdown = MarkdownProcessor::Fixer::FixAll.call(body_markdown)
    begin
      parsed = FrontMatterParser::Parser.new(:md).call(fixed_body_markdown)
      parsed.front_matter["title"].present?
    rescue Psych::SyntaxError, Psych::DisallowedClass
      # if frontmatter is invalid, still render editor with errors instead of 500ing
      true
    end
  end

  def class_name
    self.class.name
  end

  def flare_tag
    @flare_tag ||= FlareTag.new(self).tag_hash
  end

  def edited?
    edited_at.present?
  end

  def readable_edit_date
    return unless edited?

    if edited_at.year == Time.current.year
      I18n.l(edited_at, format: :short)
    else
      I18n.l(edited_at, format: :short_with_yy)
    end
  end

  def readable_publish_date
    relevant_date = displayable_published_at
    return unless relevant_date

    if relevant_date.year == Time.current.year
      I18n.l(relevant_date, format: :short)
    elsif relevant_date
      I18n.l(relevant_date, format: :short_with_yy)
    end
  end

  def published_timestamp
    return "" unless published
    return "" unless crossposted_at || published_at

    displayable_published_at.utc.iso8601
  end

  def displayable_published_at
    crossposted_at.presence || published_at
  end

  def series
    # name of series article is part of
    collection&.slug
  end

  def all_series
    # all series names
    user&.collections&.pluck(:slug)
  end

  def cloudinary_video_url
    return if video_thumbnail_url.blank?

    Images::Optimizer.call(video_thumbnail_url, width: 880, quality: 80)
  end

  def video_duration_in_minutes
    duration = ActiveSupport::Duration.build(video_duration_in_seconds.to_i).parts

    # add default hours and minutes for the substitutions below
    duration = duration.reverse_merge(seconds: 0, minutes: 0, hours: 0)

    minutes_and_seconds = format("%<minutes>02d:%<seconds>02d", duration)
    return minutes_and_seconds if duration[:hours] < 1

    "#{duration[:hours]}:#{minutes_and_seconds}"
  end

  def update_score
    self.score = reactions.sum(:points) + Reaction.where(reactable_id: user_id, reactable_type: "User").sum(:points)
    update_columns(score: score,
                   privileged_users_reaction_points_sum: reactions.privileged_category.sum(:points),
                   comment_score: comments.sum(:score),
                   hotness_score: BlackBox.article_hotness_score(self))
  end

  def co_author_ids_list=(list_of_co_author_ids)
    self.co_author_ids = list_of_co_author_ids.split(",").map(&:strip)
  end

  def plain_html
    doc = Nokogiri::HTML.fragment(processed_html)
    doc.search(".highlight__panel").each(&:remove)
    doc.to_html
  end

  def followers
    # This will return an array, but the items will NOT be ActiveRecord objects.
    # The followers may also occasionally be nil because orphaned follows can possibly exist in the database.
    followers = user.followers_scoped.where(subscription_status: "all_articles").map(&:follower)

    if organization_id
      org_followers = organization.followers_scoped.where(subscription_status: "all_articles")
      followers += org_followers.map(&:follower)
    end

    followers.uniq.compact
  end

  def all_langs
    I18n.t("languages")
  end

  def parallel_translations
    Article.where(translation_group: translation_group).where.not(translation_group: nil)
  end

  def skip_indexing?
    # should the article be skipped indexed by crawlers?
    # true if unpublished, or spammy,
    # or low score, not featured, and from a user with no comments
    !published ||
      (score < Settings::UserExperience.index_minimum_score &&
       user.comments_count < 1 &&
       !featured) ||
      published_at.to_i < 1_500_000_000 ||
      score < -1
  end

  # to be public method so that can be called from PublishWorker etc.
  def notify_external_services_on_new_post
    return unless published && !scheduled?

    if boost_states["boosted_new_post"]
      DiscordWebhook::Bot.edited_post self
    else
      TwitterClient::Bot.new_post self
      DiscordWebhook::Bot.new_post self

      boost_states["boosted_new_post"] = true
      update_columns boost_states: boost_states
    end
  end

  private

  def collection_cleanup
    # Should only check to cleanup if Article was removed from collection
    return unless saved_change_to_collection_id? && collection_id.nil?

    collection = Collection.find(collection_id_before_last_save)
    return if collection.articles.count.positive?

    # Collection is empty
    collection.destroy
  end

  def search_score
    comments_score = (comments_count * 3).to_i
    partial_score = (comments_score + (public_reactions_count.to_i * 300 * user.reputation_modifier * score.to_i))
    calculated_score = hotness_score.to_i + partial_score
    calculated_score.to_i
  end

  def tag_keywords_for_search
    tags.pluck(:keywords_for_search).join
  end

  def calculated_path
    if organization
      "/#{organization.slug}/#{slug}"
    else
      "/#{username}/#{slug}"
    end
  end

  def set_caches
    return unless user

    self.cached_user_name = user_name
    self.cached_user_username = user_username
    self.path = calculated_path.downcase
  end

  def normalize_title
    return unless title

    self.title = title
      .gsub(TITLE_CHARACTERS_ALLOWED, " ")
      # Coalesce runs of whitespace into a single space character
      .gsub(/\s+/, " ")
      .strip
  end

  def processed_content
    return @processed_content if @processed_content && !body_markdown_changed?
    return unless user

    @processed_content = ContentRenderer.new(body_markdown, source: self, user: user)
  end

  def evaluate_markdown
    if FeatureFlag.enabled?(:consistent_rendering, FeatureFlag::Actor[user])
      extracted_evaluate_markdown
    else
      original_evaluate_markdown
    end
  end

  def extracted_evaluate_markdown
    content_renderer = processed_content
    return unless content_renderer

    self.processed_html = content_renderer.process(calculate_reading_time: true)
    self.reading_time = content_renderer.reading_time

    front_matter = content_renderer.front_matter

    if front_matter.any?
      evaluate_front_matter(front_matter)
    elsif tag_list.any?
      set_tag_list(tag_list)
    end

    self.description = processed_description if description.blank?
  rescue ContentRenderer::ContentParsingError => e
    errors.add(:base, ErrorMessages::Clean.call(e.message))
  end

  def original_evaluate_markdown
    fixed_body_markdown = MarkdownProcessor::Fixer::FixAll.call(body_markdown || "")
    parsed = FrontMatterParser::Parser.new(:md).call(fixed_body_markdown)
    parsed_markdown = MarkdownProcessor::Parser.new(parsed.content, source: self, user: user)
    self.reading_time = parsed_markdown.word_char_count
    self.processed_html = parsed_markdown.finalize

    if parsed.front_matter.any?
      evaluate_front_matter(parsed.front_matter)
    elsif tag_list.any?
      set_tag_list(tag_list)
    end

    self.description = processed_description if description.blank?
  rescue StandardError => e
    errors.add(:base, ErrorMessages::Clean.call(e.message))
  end

  def set_tag_list(tags)
    self.tag_list = [] # overwrite any existing tag with those from the front matter
    tag_list.add(tags, parse: true)
    self.tag_list = tag_list.map { |tag| Tag.find_preferred_alias_for(tag) }
  end

  def async_score_calc
    return if !published? || destroyed?

    Articles::ScoreCalcWorker.perform_async(id)
  end

  def fetch_video_duration
    if video.present? && video_duration_in_seconds.zero?
      url = video_source_url.gsub(".m3u8", "1351620000001-200015_hls_v4.m3u8")
      duration = 0
      HTTParty.get(url).body.split("#EXTINF:").each do |chunk|
        duration += chunk.split(",")[0].to_f
      end
      self.video_duration_in_seconds = duration
      duration
    end
  rescue StandardError => e
    Rails.logger.error(e)
  end

  def update_notifications
    Notification.update_notifications(self, I18n.t("models.article.published"))
  end

  def update_notification_subscriptions
    NotificationSubscription.update_notification_subscriptions(self)
  end

  def before_destroy_actions
    bust_cache(destroying: true)
    article_ids = user.article_ids.dup
    if organization
      organization.touch(:last_article_at)
      article_ids.concat organization.article_ids
    end
    # perform busting cache in chunks in case there're a lot of articles
    # NOTE: `perform_bulk` takes an array of arrays as argument. Since the worker
    # takes an array of ids as argument, this becomes triple-nested.
    job_params = (article_ids.uniq.sort - [id]).each_slice(10).to_a.map { |ids| [ids] }
    Articles::BustMultipleCachesWorker.perform_bulk(job_params)
  end

  def evaluate_front_matter(hash)
    self.title = hash["title"] if hash["title"].present?
    set_tag_list(hash["tags"]) if hash["tags"].present?
    self.published = hash["published"] if %w[true false].include?(hash["published"].to_s)

    self.published_at = hash["published_at"] if hash["published_at"]
    self.published_at ||= parse_date(hash["date"]) if published

    set_main_image(hash)
    self.canonical_url = hash["canonical_url"] if hash["canonical_url"].present?

    update_description = hash["description"].present? || hash["title"].present?
    self.description = hash["description"] if update_description

    self.collection_id = nil if hash["title"].present?
    self.collection_id = Collection.find_series(hash["series"], user).id if hash["series"].present?
  end

  def set_main_image(hash)
    # At one point, we have set the main_image based on the front matter. Forever will that now dictate the behavior.
    if main_image_from_frontmatter?
      self.main_image = hash["cover_image"]
    elsif hash.key?("cover_image")
      # They've chosen the set cover image in the front matter, so we'll proceed with that assumption.
      self.main_image = hash["cover_image"]
      self.main_image_from_frontmatter = true
    end
  end

  def parse_date(date)
    # once published_at exist, it can not be adjusted
    published_at || date || Time.current
  end

  def validate_tag
    # remove adjusted tags
    remove_tag_adjustments_from_tag_list
    add_tag_adjustments_to_tag_list

    # check there are not too many tags
    return errors.add(:tag_list, I18n.t("models.article.too_many_tags")) if tag_list.size > MAX_TAG_LIST_SIZE

    validate_tag_name(tag_list)
  end

  def remove_tag_adjustments_from_tag_list
    tags_to_remove = TagAdjustment.where(article_id: id, adjustment_type: "removal",
                                         status: "committed").pluck(:tag_name)
    tag_list.remove(tags_to_remove, parse: true) if tags_to_remove.present?
  end

  def add_tag_adjustments_to_tag_list
    tags_to_add = TagAdjustment.where(article_id: id, adjustment_type: "addition", status: "committed").pluck(:tag_name)
    return if tags_to_add.blank?

    tag_list.add(tags_to_add, parse: true)
    self.tag_list = tag_list.map { |tag| Tag.find_preferred_alias_for(tag) }
  end

  def validate_video
    if published && video_state == "PROGRESSING"
      return errors.add(:published,
                        I18n.t("models.article.video_processing"))
    end

    return unless video.present? && user.created_at > 2.weeks.ago

    errors.add(:video, I18n.t("models.article.video_unpermitted"))
  end

  def validate_collection_permission
    return unless collection && collection.user_id != user_id

    errors.add(:collection_id, I18n.t("models.article.series_unpermitted"))
  end

  def validate_co_authors
    return if co_author_ids.exclude?(user_id)

    errors.add(:co_author_ids, I18n.t("models.article.same_author"))
  end

  def validate_co_authors_must_not_be_the_same
    return if co_author_ids.uniq.count == co_author_ids.count

    errors.add(:base, I18n.t("models.article.unique_coauthor"))
  end

  def validate_co_authors_exist
    return if User.where(id: co_author_ids).count == co_author_ids.count

    errors.add(:co_author_ids, I18n.t("models.article.invalid_coauthor"))
  end

  def future_or_current_published_at
    # allow published_at in the future or within 15 minutes in the past
    return if !published || published_at > 15.minutes.ago

    errors.add(:published_at, I18n.t("models.article.future_or_current_published_at"))
  end

  def correct_published_at?
    return unless changes["published_at"]

    # for drafts (that were never published before) or scheduled articles
    # => allow future or current dates, or no published_at
    if !published_at_was || published_at_was > Time.current
      # for articles published_from_feed (exported from rss) we allow past published_at
      if (published_at && published_at < 15.minutes.ago) && !published_from_feed
        errors.add(:published_at, I18n.t("models.article.future_or_current_published_at"))
      end
    else
      # for articles that have been published already (published or unpublished drafts) => immutable published_at
      # allow changes within one minute in case of editing via frontmatter w/o specifying seconds
      has_nils = changes["published_at"].include?(nil) # changes from nil or to nil
      close_enough = !has_nils && (published_at_was - published_at).between?(-60, 60)
      errors.add(:published_at, I18n.t("models.article.immutable_published_at")) if has_nils || !close_enough
    end
  end

  def canonical_url_must_not_have_spaces
    return unless canonical_url.to_s.match?(/[[:space:]]/)

    errors.add(:canonical_url, I18n.t("models.article.must_not_have_spaces"))
  end

  def user_mentions_in_markdown
    return if created_at.present? && created_at.before?(MAX_USER_MENTION_LIVE_AT)

    # The "mentioned-user" css is added by Html::Parser#user_link_if_exists
    mentions_count = Nokogiri::HTML(processed_html).css(".mentioned-user").size
    return if mentions_count <= Settings::RateLimit.mention_creation

    errors.add(:base,
               I18n.t("models.article.mention_too_many", count: Settings::RateLimit.mention_creation))
  end

  def create_slug
    if slug.blank? && title.present? && !published
      self.slug = title_to_slug + "-temp-slug-#{rand(10_000_000)}"
    elsif should_generate_final_slug?
      self.slug = title_to_slug
    end
  end

  def should_generate_final_slug?
    (title && published && slug.blank?) ||
      (title && published && slug.include?("-temp-slug-"))
  end

  def create_password
    return if password.present?

    self.password = SecureRandom.hex(60)
  end

  def set_cached_entities
    self.cached_organization = organization ? Articles::CachedEntity.from_object(organization) : nil
    self.cached_user = user ? Articles::CachedEntity.from_object(user) : nil
  end

  def set_all_dates
    set_crossposted_at
    set_last_comment_at
    set_nth_published_at
  end

  def set_published_date
    self.published_at = Time.current if published && published_at.blank?
  end

  def set_crossposted_at
    self.crossposted_at = Time.current if published && crossposted_at.blank? && published_from_feed
  end

  def set_last_comment_at
    return unless published_at.present? && last_comment_at == "Sun, 01 Jan 2017 05:00:00 UTC +00:00"

    self.last_comment_at = published_at
    user.touch(:last_article_at)
    organization&.touch(:last_article_at)
  end

  def set_nth_published_at
    return unless nth_published_by_author.zero? && published

    published_article_ids = user.articles.published.order(published_at: :asc).ids
    index = published_article_ids.index(id)

    self.nth_published_by_author = (index || published_article_ids.size) + 1
  end

  def title_to_slug
    "#{sluggify(title, base_lang).tr('_', '')}-#{rand(100_000).to_s(26)}"
  end

  def touch_actor_latest_article_updated_at(destroying: false)
    return unless destroying || saved_changes.keys.intersection(%w[title cached_tag_list]).present?

    user.touch(:latest_article_updated_at)
    organization&.touch(:latest_article_updated_at)
  end

  def bust_cache(destroying: false)
    cache_bust = EdgeCache::Bust.new
    cache_bust.call(path)
    cache_bust.call("#{path}?i=i")
    cache_bust.call("#{path}?preview=#{password}")
    async_bust
    touch_actor_latest_article_updated_at(destroying: destroying)
  end

  def calculate_base_scores
    self.hotness_score = 1000 if hotness_score.blank?
  end

  def create_conditional_autovomits
    Spam::Handler.handle_article!(article: self)
  end

  def async_bust
    Articles::BustCacheWorker.perform_async(id)
  end

  def touch_collection
    collection.touch if collection && previous_changes.present?
  end

  def enrich_image_attributes
    return unless saved_change_to_attribute?(:processed_html)

    ::Articles::EnrichImageAttributesWorker.perform_async(id)
  end

  def eponymous_translation_group
    return unless translation_group && id != translation_group

    original = Article.find translation_group
    original.update_columns(translation_group: translation_group) unless original.translation_group
  end

  def remove_prohibited_unicode_characters
    return unless title&.match?(BIDI_CONTROL_CHARACTERS)

    bidi_stripped = title.gsub(BIDI_CONTROL_CHARACTERS, "")
    self.title = bidi_stripped if bidi_stripped.blank? # title only contains BIDI characters = blank title
  end

  def record_field_test_event
    return unless published?
    return if FieldTest.config["experiments"].nil?

    Users::RecordFieldTestEventWorker
      .perform_async(user_id, AbExperiment::GoalConversionHandler::USER_PUBLISHES_POST_GOAL)
  end
end
