module Constants
  module Settings
    module General
      IMAGE_PLACEHOLDER = "https://url/image.png".freeze

      DETAILS = {
        contact_email: {
          description: "Used for contact links. Please provide an email address where users " \
                       "can get in touch with you or your team.",
          placeholder: "hello@example.com"
        },
        credit_prices_in_cents: {
          small: {
            description: "Price for small credit purchase (<10 credits).",
            placeholder: ""
          },
          health_check_token: {
            description: I18n.t("lib.constants.settings.general.used_to_authenticate_with"),
            placeholder: I18n.t("lib.constants.settings.general.a_secure_token")
          },
          logo_png: {
            description: I18n.t("lib.constants.settings.general.used_as_a_fallback_to_the"),
            placeholder: IMAGE_PLACEHOLDER
          },
          logo_svg: {
            description: I18n.t("lib.constants.settings.general.used_as_the_svg_logo_of_th"),
            placeholder: SVG_PLACEHOLDER
          },
          main_social_image: {
            description: I18n.t("lib.constants.settings.general.used_as_the_main_image_in"),
            placeholder: IMAGE_PLACEHOLDER
          },
          mailchimp_api_key: {
            description: I18n.t("lib.constants.settings.general.api_key_used_to_connect_ma"),
            placeholder: ""
          },
          mailchimp_newsletter_id: {
            description: I18n.t("lib.constants.settings.general.main_newsletter_id_also_kn"),
            placeholder: ""
          },
          mailchimp_sustaining_members_id: {
            description: I18n.t("lib.constants.settings.general.sustaining_members_newslet"),
            placeholder: ""
          },
          mailchimp_tag_moderators_id: {
            description: I18n.t("lib.constants.settings.general.tag_moderators_newsletter"),
            placeholder: ""
          },
          mailchimp_community_moderators_id: {
            description: I18n.t("lib.constants.settings.general.community_moderators_newsl"),
            placeholder: ""
          },
          mascot_image_url: {
            description: I18n.t("lib.constants.settings.general.used_as_the_mascot_image"),
            placeholder: IMAGE_PLACEHOLDER
          },
          mascot_user_id: {
            description: I18n.t("lib.constants.settings.general.user_id_of_the_mascot_acco"),
            placeholder: "1"
          },
          meta_keywords: {
            description: "",
            placeholder: I18n.t("lib.constants.settings.general.list_of_valid_keywords_com")
          },
          onboarding_background_image: {
            description: I18n.t("lib.constants.settings.general.background_for_onboarding"),
            placeholder: IMAGE_PLACEHOLDER
          },
          payment_pointer: {
            description: I18n.t("lib.constants.settings.general.used_for_site_wide_web_mon"),
            placeholder: "$pay.somethinglikethis.co/value"
          },
          periodic_email_digest: {
            description: I18n.t("lib.constants.settings.general.determines_how_often_perio"),
            placeholder: 2
          },
          sidebar_tags: {
            description: I18n.t("lib.constants.settings.general.determines_which_tags_are"),
            placeholder: I18n.t("lib.constants.settings.general.list_of_valid_comma_separa")
          },
          sponsor_headline: {
            description: I18n.t("lib.constants.settings.general.determines_the_heading_tex"),
            placeholder: I18n.t("lib.constants.settings.general.community_sponsors")
          },
          stripe_api_key: {
            description: I18n.t("lib.constants.settings.general.secret_stripe_key_for_rece"),
            placeholder: "sk_live_...."
          },
          stripe_publishable_key: {
            description: I18n.t("lib.constants.settings.general.public_stripe_key_for_rece"),
            placeholder: "pk_live_...."
          },
          suggested_tags: {
            description: I18n.t("lib.constants.settings.general.determines_which_tags_are2"),
            placeholder: I18n.t("lib.constants.settings.general.list_of_valid_tags_comma_s")
          },
          suggested_users: {
            description: I18n.t("lib.constants.settings.general.determines_which_users_are"),
            placeholder: I18n.t("lib.constants.settings.general.list_of_valid_usernames_co")
          },
          prefer_manual_suggested_users: {
            description: I18n.t("lib.constants.settings.general.always_show_suggested_user")
          },
          twitter_hashtag: {
            description: I18n.t("lib.constants.settings.general.used_as_the_twitter_hashta"),
            placeholder: I18n.t("lib.constants.settings.general.devcommunity")
          },
          video_encoder_key: {
            description: I18n.t("lib.constants.settings.general.secret_key_used_to_allow_a"),
            placeholder: ""
          }
        },
        favicon_url: {
          description: "Used as the site favicon",
          placeholder: IMAGE_PLACEHOLDER
        },
        ga_tracking_id: {
          description: "Google Analytics Tracking ID, e.g. UA-71991000-1",
          placeholder: ""
        },
        health_check_token: {
          description: "Used to authenticate with your health check endpoints.",
          placeholder: "a secure token"
        },
        logo_png: {
          description: "Used as a secondary logo in places like the sign in modals, onboarding, Apple touch icons. " \
                       "Recommended minimum of 512x512px",
          placeholder: IMAGE_PLACEHOLDER
        },
        main_social_image: {
          description: "Used as the main image in social networks and OpenGraph. Recommended aspect ratio " \
                       "of 16:9 (600x337px,1200x675px)",
          placeholder: IMAGE_PLACEHOLDER
        },
        mailchimp_api_key: {
          description: "API key used to connect Mailchimp account. Found in Mailchimp backend",
          placeholder: ""
        },
        mailchimp_newsletter_id: {
          description: "Main Newsletter ID, also known as Audience ID",
          placeholder: ""
        },
        mailchimp_sustaining_members_id: {
          description: "Sustaining Members Newsletter ID",
          placeholder: ""
        },
        mailchimp_tag_moderators_id: {
          description: "Tag Moderators Newsletter ID",
          placeholder: ""
        },
        mailchimp_community_moderators_id: {
          description: "Community Moderators Newsletter ID",
          placeholder: ""
        },
        mascot_image_url: {
          description: "Used as the mascot image.",
          placeholder: IMAGE_PLACEHOLDER
        },
        mascot_user_id: {
          description: "User ID of the Mascot account",
          placeholder: "1"
        },
        meta_keywords: {
          description: "",
          placeholder: "List of valid keywords: comma separated, letters only e.g. engineering, development"
        },
        onboarding_background_image: {
          description: "Background for onboarding splash page",
          placeholder: IMAGE_PLACEHOLDER
        },
        payment_pointer: {
          description: "Used for site-wide web monetization. " \
                       "See: https://github.com/thepracticaldev/dev.to/pull/6345",
          placeholder: "$pay.somethinglikethis.co/value"
        },
        periodic_email_digest: {
          description: "Determines how often email digests are sent (in days)",
          placeholder: 2
        },
        sidebar_tags: {
          description: "Determines which tags are shown on the homepage right-hand sidebar",
          placeholder: "List of valid, comma-separated tags e.g. help,discuss,explainlikeimfive,meta"
        },
        sponsor_headline: {
          description: "Determines the heading text of the main sponsors sidebar above the list of sponsors.",
          placeholder: "Community Sponsors"
        },
        stripe_api_key: {
          description: "Secret Stripe key for receiving payments. " \
                       "See: https://stripe.com/docs/keys",
          placeholder: "sk_live_...."
        },
        stripe_publishable_key: {
          description: "Public Stripe key for receiving payments. " \
                       "See: https://stripe.com/docs/keys",
          placeholder: "pk_live_...."
        },
        suggested_tags: {
          description:
            "Determines which tags are suggested to new users during onboarding (comma separated, letters only)",
          placeholder: "List of valid tags: comma separated, letters only e.g. beginners,javascript,ruby,swift,kotlin"
        },
        suggested_users: {
          description: "Determines which users are suggested to follow to new users during onboarding (comma " \
                       "separated, letters only). Please note that these users will be shown as a fallback if no " \
                       "recently-active commenters or producers can be suggested",
          placeholder: "List of valid usernames: comma separated, letters only e.g. " \
                       "ben,jess,peter,maestromac,andy,liana"
        },
        prefer_manual_suggested_users: {
          description: "Always show suggested users as suggested people to follow even when " \
                       "auto-suggestion is available"
        },
        twitter_hashtag: {
          description: "Used as the twitter hashtag of the community",
          placeholder: "#DEVCommunity"
        },
        video_encoder_key: {
          description: "Secret key used to allow AWS video encoding through the VideoStatesController",
          placeholder: ""
        }
      end
    end
  end
end
