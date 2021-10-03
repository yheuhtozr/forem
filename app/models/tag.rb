class Tag < ActsAsTaggableOn::Tag
  attr_accessor :points, :tag_moderator_id, :remove_moderator_id

  acts_as_followable
  resourcify

  # This model doesn't inherit from ApplicationRecord so this has to be included
  include Purgeable
  include PgSearch::Model

  ALLOWED_CATEGORIES = %w[uncategorized language library tool site_mechanic location subcommunity].freeze
  HEX_COLOR_REGEXP = /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/
  # our tag format largely follows the UAX #31 identifier pattern, with heuristic extension in repertoire
  TAG_PATTERN = /\A
    # initial character is:
    [\p{XIDS}\p{Nd}\p{No}]
    #   ^ XID_Start: (L + Nl + Other_ID_Start) − Pattern_Syntax − Pattern_White_Space
    #           ^ or decimal numerals
    #                 ^ or other numerals
    (?:
    # medial characters are:
      [\p{XIDC}\p{No}\u00B7\u05F3\u05F4\u0F0B\u200C\u200D]*
      #   ^ XID_Continue: (ID_Start + Mn + Mc + Nd + Pc + Other_ID_Continue) - Pattern_Syntax - Pattern_White_Space
      #           ^ or other numerals
      #              ^ or MIDDLE DOT
      #                    ^ or HEBREW PUNCTUATION GERESH
      #                          ^ or HEBREW PUNCTUATION GERSHAYIM
      #                                ^ or TIBETAN MARK INTERSYLLABIC TSHEG
      #                                      ^ or ZERO WIDTH NON-JOINER
      #                                            ^ or ZERO WIDTH JOINER
    # final character is:
      [\p{XIDC}\p{No}\u0F0B]
      #   ^ XID_Continue
      #           ^ or other numerals
      #              ^ or TIBETAN MARK INTERSYLLABIC TSHEG
    )?
  \z/ux

  belongs_to :badge, optional: true
  belongs_to :mod_chat_channel, class_name: "ChatChannel", optional: true

  has_many :articles, through: :taggings, source: :taggable, source_type: "Article"

  has_one :sponsorship, as: :sponsorable, inverse_of: :sponsorable, dependent: :destroy

  mount_uploader :profile_image, ProfileImageUploader
  mount_uploader :social_image, ProfileImageUploader

  validates :text_color_hex, format: HEX_COLOR_REGEXP, allow_nil: true
  validates :bg_color_hex, format: HEX_COLOR_REGEXP, allow_nil: true
  validates :category, presence: true, inclusion: { in: ALLOWED_CATEGORIES }

  validate :validate_alias_for, if: :alias_for?
  validate :validate_name, if: :name?

  before_validation :normalize_names # not sure if working on save
  before_validation :evaluate_markdown
  before_validation :pound_it

  before_save :calculate_hotness_score
  before_save :mark_as_updated

  after_commit :bust_cache

  pg_search_scope :search_by_name,
                  against: :name,
                  using: { tsearch: { prefix: true } }

  scope :eager_load_serialized_data, -> {}
  scope :supported, -> { where(supported: true) }

  # possible social previews templates for articles with a particular tag
  def self.social_preview_templates
    Rails.root.join("app/views/social_previews/articles").children.map { |ch| File.basename(ch, ".html.erb") }
  end

  def submission_template_customized(param_0 = nil)
    submission_template&.gsub("PARAM_0", param_0)
  end

  def tag_moderator_ids
    User.with_role(:tag_moderator, self).order(id: :asc).ids
  end

  def self.valid_categories
    ALLOWED_CATEGORIES
  end

  def self.aliased_name(word)
    tag = find_by(name: word.downcase)
    return unless tag

    tag.alias_for.presence || tag.name
  end

  def self.find_preferred_alias_for(word)
    find_by(name: word.downcase)&.alias_for.presence || word.downcase
  end

  def validate_name
    errors.add(:name, I18n.t("v.tags.error.length")) if name.length > 30
    errors.add(:name, I18n.t("v.tags.error.chars")) unless name.match?(TAG_PATTERN)
  end

  def errors_as_sentence
    errors.full_messages.to_sentence
  end

  def self.smart_tr(str)
    str.tr("'", ?\u02BC) # ASCII apostrophe to MODIFIER LETTER APOSTROPHE
  end

  def quick_validate
    self.name = Tag.smart_tr name.normalize
    validate_name
  end

  private

  def evaluate_markdown
    self.rules_html = MarkdownProcessor::Parser.new(rules_markdown).evaluate_markdown
    self.wiki_body_html = MarkdownProcessor::Parser.new(wiki_body_markdown).evaluate_markdown
  end

  def calculate_hotness_score
    self.hotness_score = Article.tagged_with(name)
      .where("articles.featured_number > ?", 7.days.ago.to_i)
      .sum do |article|
        (article.comments_count * 14) + article.score + rand(6) + ((taggings_count + 1) / 2)
      end
  end

  def bust_cache
    Tags::BustCacheWorker.perform_async(name)
    Rails.cache.delete("view-helper-#{name}/tag_colors")
  end

  def validate_alias_for
    return if Tag.exists?(name: alias_for)

    errors.add(:tag, "alias_for must refer to an existing tag")
  end

  def pound_it
    text_color_hex&.prepend("#") unless text_color_hex&.starts_with?("#") || text_color_hex.blank?
    bg_color_hex&.prepend("#") unless bg_color_hex&.starts_with?("#") || bg_color_hex.blank?
  end

  def mark_as_updated
    self.updated_at = Time.current # Acts-as-taggable didn't come with this by default
  end

  def normalize_names
    self.name = Tag.smart_tr name.normalize if name
    self.alias_for = Tag.smart_tr alias_for.normalize if alias_for
  end
end
