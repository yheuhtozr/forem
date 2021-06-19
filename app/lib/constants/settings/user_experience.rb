module Constants
  module Settings
    module UserExperience
      def self.details
        {
          default_font: {
            description: I18n.t("lib.constants.settings.user_experience.determines_the_default_rea")
          },
          feed_strategy: {
            description: "Determines the main feed algorithm approach the app takes: basic or large_forem_experimental
        (which should only be used for 10k+ member communities)",
            placeholder: "basic"
          },
          feed_style: {
            description: I18n.t("lib.constants.settings.user_experience.determines_which_default_f"),
            placeholder: I18n.t("lib.constants.settings.user_experience.basic_rich_or_compact")
          },
          home_feed_minimum_score: {
            description: I18n.t("lib.constants.settings.user_experience.minimum_score_needed_for_a"),
            placeholder: "0"
          },
          primary_brand_color_hex: {
            description: I18n.t("lib.constants.settings.user_experience.determines_background_bord"),
            placeholder: "#0a0a0a"
          },
          tag_feed_minimum_score: {
            description: I18n.t("lib.constants.settings.user_experience.minimum_score_needed_for_a2"),
            placeholder: "0"
          }
        }
      end
    end
  end
end
