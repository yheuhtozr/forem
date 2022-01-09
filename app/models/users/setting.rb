module Users
  class Setting < ApplicationRecord
    self.table_name_prefix = "users_"

    HEX_COLOR_REGEXP = /\A#?(?:\h{6}|\h{3})\z/

    belongs_to :user, touch: true
    scope :with_feed, -> { where.not(feed_url: [nil, ""]) }

    enum editor_version: { v2: 0, v1: 1 }, _suffix: :editor
    enum config_font: { default: 0, comic_sans: 1, monospace: 2, open_dyslexic: 3, sans_serif: 4, serif: 5 },
         _suffix: :font
    enum inbox_type: { private: 0, open: 1 }, _suffix: :inbox
    enum config_navbar: { default: 0, static: 1 }, _suffix: :navbar
    # NOTE: We previously had a set of 5 themes with values from 0 to 4.
    enum config_theme: { light_theme: 0, minimal_theme: 1, dark_theme: 2 }
    enum config_homepage_feed: { default: 0, latest: 1, top_week: 2, top_month: 3, top_year: 4, top_infinity: 5 },
         _suffix: :feed

    validates :brand_color1,
              :brand_color2,
              format: { with: HEX_COLOR_REGEXP,
                        message: I18n.t("validators.profile_validator.is_not_a_valid_hex_color") },
              allow_nil: true
    validates :user_id, presence: true
    validates :experience_level, numericality: { less_than_or_equal_to: 10 }, allow_blank: true
    validates :feed_referential_link, inclusion: { in: [true, false] }
    validates :feed_url, length: { maximum: 500 }, allow_nil: true
    validates :inbox_guidelines, length: { maximum: 250 }, allow_nil: true
    validates :writing_lang, format: {
      with: /\A[0-9A-Za-z]{1,8}(?:-[0-9A-Za-z]{1,8})*\z/,
      message: proc { I18n.t("common.invalid_langtag") }
    }, allow_blank: true

    validate :validate_feed_url, if: :feed_url_changed?

    def resolved_font_name
      config_font.gsub("default", Settings::UserExperience.default_font)
    end

    private

    def validate_feed_url
      return if feed_url.blank?

      valid = Feeds::ValidateUrl.call(feed_url)

      errors.add(:feed_url, I18n.t("models.user.is_not_a_valid_rss_atom_fe")) unless valid
    rescue StandardError => e
      errors.add(:feed_url, e.message)
    end
  end
end
