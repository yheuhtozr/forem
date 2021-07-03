require "rails_helper"

RSpec.describe "/admin/customization/config", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:super_admin) { create(:user, :super_admin) }
  let(:confirmation_message) do
    "My username is @#{super_admin.username} and this action is 100% safe and appropriate."
  end

  describe "POST /admin/customization/config as a user" do
    before do
      sign_in(user)
    end

    it "bars the regular user to access" do
      expect { post admin_settings_general_settings_path, params: {} }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  # rubocop:disable RSpec/NestedGroups
  describe "POST /admin/customization/config" do
    context "when admin has typical admin permissions but not super admin" do
      before do
        sign_in(admin)
      end

      it "does not allow user to update config if they have proper confirmation" do
        expected_image_url = "https://dummyimage.com/300x300.png"
        expect do
          post admin_settings_general_settings_path, params: {
            settings_general: { favicon_url: expected_image_url },
            confirmation: confirmation_message
          }
        end.to raise_error Pundit::NotAuthorizedError
      end

      it "does not allow user to update config if they do not have proper confirmation" do
        expected_image_url = "https://dummyimage.com/300x300.png"
        expect do
          post admin_settings_general_settings_path, params: {
            settings_general: { favicon_url: expected_image_url },
            confirmation: "Not proper"
          }
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when admin has full permissions including super" do
      before do
        sign_in(super_admin)
      end

      it "updates settings admin action taken" do
        expect do
          post admin_settings_general_settings_path, params: {
            settings_general: { health_check_token: "token" },
            confirmation: confirmation_message
          }
        end.to change(Settings::General, :admin_action_taken_at)
      end

      describe "API tokens" do
        it "updates the health_check_token" do
          token = rand(20).to_s
          post admin_settings_general_settings_path, params: {
            settings_general: { health_check_token: token },
            confirmation: confirmation_message
          }
          expect(Settings::General.health_check_token).to eq token
        end

        it "sets video_encoder_key" do
          post admin_settings_general_settings_path, params: {
            settings_general: { video_encoder_key: "123abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.video_encoder_key).to eq("123abc")
        end
      end

      describe "Authentication" do
        let(:provider) { "twitter" }

        before do
          allow(Authentication::Providers).to receive(:available).and_return([provider])
        end

        it "updates enabled authentication providers" do
          post admin_settings_authentications_path, params: {
            settings_authentication: {
              "#{provider}_key": "someKey",
              "#{provider}_secret": "someSecret",
              auth_providers_to_enable: provider
            },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.providers).to eq([provider])
        end

        it "strips empty elements" do
          enabled = "#{provider}, '', nil"
          post admin_settings_authentications_path, params: {
            settings_authentication: {
              "#{provider}_key": "someKey",
              "#{provider}_secret": "someSecret",
              auth_providers_to_enable: enabled
            },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.providers).to eq([provider])
        end

        it "does not update enabled authentication providers if any associated key missing" do
          allow(Settings::Authentication).to receive(:"#{provider}_secret").and_return(nil)

          post admin_settings_authentications_path, params: {
            settings_authentication: {
              "#{provider}_key": "someKey",
              "#{provider}_secret": "",
              auth_providers_to_enable: provider
            },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.providers).to eq([])
        end

        it "enables proper domains to allow list" do
          proper_list = "dev.to, forem.com, forem.dev"
          post admin_settings_authentications_path, params: {
            settings_authentication: { allowed_registration_email_domains: proper_list },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.allowed_registration_email_domains).to eq(%w[dev.to forem.com forem.dev])
        end

        it "allows 2-character domains" do
          proper_list = "dev.to, forem.com, 2u.com"
          post admin_settings_authentications_path, params: {
            settings_authentication: { allowed_registration_email_domains: proper_list },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.allowed_registration_email_domains).to eq(%w[dev.to forem.com 2u.com])
        end

        it "does not allow improper domain list" do
          impproper_list = "dev.to, foremcom, forem.dev"
          post admin_settings_authentications_path, params: {
            settings_authentication: { allowed_registration_email_domains: impproper_list },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.allowed_registration_email_domains).not_to eq(%w[dev.to foremcom forem.dev])
        end

        it "enables display_email_domain_allow_list_publicly" do
          post admin_settings_authentications_path, params: {
            settings_authentication: { display_email_domain_allow_list_publicly: true },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.display_email_domain_allow_list_publicly).to be(true)
        end

        it "enables email authentication" do
          post admin_settings_authentications_path, params: {
            settings_authentication: { allow_email_password_registration: true },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.allow_email_password_registration).to be(true)
          expect(Settings::Authentication.allow_email_password_login).to be(true)
        end

        it "disables email authentication" do
          post admin_settings_authentications_path, params: {
            settings_authentication: { allow_email_password_registration: false },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.allow_email_password_registration).to be(false)
          expect(Settings::Authentication.allow_email_password_login).to be(true)
        end

        it "enables invite-only-mode" do
          post admin_settings_authentications_path, params: {
            settings_authentication: { invite_only_mode: true },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.invite_only_mode).to be(true)
        end

        it "disables invite-only-mode & enables just email registration" do
          post admin_settings_authentications_path, params: {
            settings_authentication: { invite_only_mode: false },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.invite_only_mode).to be(false)
        end
      end

      describe "Campaigns" do
        it "sets articles_expiry_time" do
          post admin_settings_campaigns_path, params: {
            settings_campaign: { articles_expiry_time: 4 },
            confirmation: confirmation_message
          }
          expect(Settings::Campaign.articles_expiry_time).to eq(4)
        end
      end

      describe "Community Content" do
        it "updates the community_description" do
          allow(Settings::Community).to receive(:community_description).and_call_original
          description = "Hey hey #{rand(100)}"
          post admin_settings_communities_path, params: {
            settings_community: { community_description: description },
            confirmation: confirmation_message
          }
          expect(Settings::Community.community_description).to eq(description)
        end

        it "updates the community_emoji if valid" do
          allow(Settings::Community).to receive(:community_emoji).and_call_original
          emoji = "🥐"
          post admin_settings_communities_path, params: {
            settings_community: { community_emoji: emoji },
            confirmation: confirmation_message
          }
          expect(Settings::Community.community_emoji).to eq(emoji)
        end

        it "does not update the community_emoji if invalid" do
          Settings::Community.community_emoji = "🥐"
          not_an_emoji = "i love croissants"
          expect do
            post admin_settings_communities_path, params: {
              settings_community: { community_emoji: not_an_emoji },
              confirmation: confirmation_message
            }
          end.not_to change(Settings::Community, :community_emoji)
        end

        it "updates the community_name" do
          name_magoo = "Hey hey #{rand(100)}"
          post admin_settings_communities_path, params: {
            settings_community: { community_name: name_magoo },
            confirmation: confirmation_message
          }
          expect(Settings::Community.community_name).to eq(name_magoo)
        end

        it "updates the community_member_label" do
          name = "developer"
          post admin_settings_communities_path, params: {
            settings_community: { member_label: name },
            confirmation: confirmation_message
          }
          expect(Settings::Community.member_label).to eq(name)
        end

        it "updates the copyright_start_year" do
          year = "2018"
          post admin_settings_communities_path, params: {
            settings_community: { copyright_start_year: year },
            confirmation: confirmation_message
          }
          expect(Settings::Community.copyright_start_year).to eq(2018)
        end

        it "updates the tagline" do
          description = "Hey hey #{rand(100)}"
          post admin_settings_communities_path, params: {
            settings_community: { tagline: description },
            confirmation: confirmation_message
          }
          expect(Settings::Community.tagline).to eq(description)
        end

        it "updates the staff_user_id" do
          post admin_settings_communities_path, params: {
            settings_community: { staff_user_id: 22 },
            confirmation: confirmation_message
          }
          expect(Settings::Community.staff_user_id).to eq(22)
        end
      end

      describe "Emails" do
        it "does not update the default email address" do
          post admin_settings_general_settings_path, params: {
            settings_general: { email_addresses: { default: "random@example.com" } },
            confirmation: confirmation_message
          }

          expect(ForemInstance.email).not_to eq("random@example.com")
        end
      end

      describe "Email digest frequency" do
        it "updates periodic_email_digest" do
          post admin_settings_general_settings_path, params: {
            settings_general: { periodic_email_digest: 1 },
            confirmation: confirmation_message
          }
          expect(Settings::General.periodic_email_digest).to eq(1)
        end

        it "rejects update without proper confirmation" do
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { periodic_email_digest: 6 },
              confirmation: "Incorrect yo!"
            }
          end.to raise_error ActionController::BadRequest
          expect(Settings::General.periodic_email_digest).not_to eq(6)
        end
      end

      describe "Google Analytics Reporting API v4" do
        it "updates ga_tracking_id" do
          post admin_settings_general_settings_path, params: {
            settings_general: { ga_tracking_id: "abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.ga_tracking_id).to eq("abc")
        end
      end

      describe "Images" do
        it "updates main_social_image" do
          expected_default_image_url = URL.local_image("social-media-cover.png")
          expect(Settings::General.main_social_image).to eq(expected_default_image_url)

          expected_image_url = "https://dummyimage.com/300x300.png"
          post admin_settings_general_settings_path, params: {
            settings_general: { main_social_image: expected_image_url },
            confirmation: confirmation_message
          }
          expect(Settings::General.main_social_image).to eq(expected_image_url)
        end

        it "updates main_social_image with a valid image" do
          expected_image = "https://dummyimage.com/300x300"

          post admin_settings_general_settings_path, params: {
            settings_general: { main_social_image: expected_image },
            confirmation: confirmation_message
          }
          expect(Settings::General.main_social_image).to eq(expected_image)
        end

        it "only updates the main_social_image if given a valid image URL" do
          invalid_image_url = "![logo_lowres]https://dummyimage.com/300x300"
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { main_social_image: invalid_image_url },
              confirmation: confirmation_message
            }
          end.not_to change(Settings::General, :main_social_image)
        end

        it "updates favicon_url" do
          expected_image_url = "https://dummyimage.com/300x300.png"
          post admin_settings_general_settings_path, params: {
            settings_general: { favicon_url: expected_image_url },
            confirmation: confirmation_message
          }
          expect(Settings::General.favicon_url).to eq(expected_image_url)
        end

        it "updates logo_png" do
          expected_default_image_url = Settings::General.get_default(:logo_png)
          expected_image_url = "https://dummyimage.com/300x300.png"
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { logo_png: expected_image_url },
              confirmation: confirmation_message
            }
          end.to change(Settings::General, :logo_png).from(expected_default_image_url).to(expected_image_url)
        end

        it "updates logo_png with a valid image" do
          expected_image = "https://dummyimage.com/300x300"

          post admin_settings_general_settings_path, params: {
            settings_general: { logo_png: expected_image },
            confirmation: confirmation_message
          }
          expect(Settings::General.logo_png).to eq(expected_image)
        end

        it "only updates the logo_png if given a valid image URL" do
          invalid_image_url = "![logo_lowres]https://dummyimage.com/300x300.png"
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { logo_png: invalid_image_url },
              confirmation: confirmation_message
            }
          end.not_to change(Settings::General, :logo_png)
        end

        it "updates logo_svg" do
          expected_image_url = "https://dummyimage.com/300x300.png"
          post admin_settings_general_settings_path, params: {
            settings_general: { logo_svg: expected_image_url },
            confirmation: confirmation_message
          }
          expect(Settings::General.logo_svg).to eq(expected_image_url)
        end

        it "rejects update without proper confirmation" do
          expected_image_url = "https://dummyimage.com/300x300.png"
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { logo_svg: expected_image_url },
              confirmation: "Incorrect yo!"
            }
          end.to raise_error ActionController::BadRequest
        end

        it "rejects update without any confirmation" do
          expected_image_url = "https://dummyimage.com/300x300.png"
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { logo_svg: expected_image_url },
              confirmation: ""
            }
          end.to raise_error ActionController::ParameterMissing
        end
      end

      describe "Mascot" do
        it "updates the mascot_user_id" do
          expected_mascot_user_id = 2
          post admin_settings_general_settings_path, params: {
            settings_general: { mascot_user_id: expected_mascot_user_id },
            confirmation: confirmation_message
          }
          expect(Settings::General.mascot_user_id).to eq(expected_mascot_user_id)
        end

        it "updates image_url" do
          expected_default_image_url = Settings::General.get_default(:mascot_image_url)
          expected_image_url = "https://dummyimage.com/300x300.png"
          expect do
            post admin_settings_general_settings_path, params: {
              settings_general: { mascot_image_url: expected_image_url },
              confirmation: confirmation_message
            }
          end.to change(Settings::General, :mascot_image_url).from(expected_default_image_url).to(expected_image_url)
        end
      end

      describe "Meta Keywords" do
        it "updates meta keywords" do
          expected_keywords = { "default" => "software, people", "article" => "user, experience", "tag" => "bye" }
          post admin_settings_general_settings_path, params: {
            settings_general: { meta_keywords: expected_keywords },
            confirmation: confirmation_message
          }
          expect(Settings::General.meta_keywords[:default]).to eq("software, people")
          expect(Settings::General.meta_keywords[:article]).to eq("user, experience")
          expect(Settings::General.meta_keywords[:tag]).to eq("bye")
        end
      end

      describe "Monetization" do
        it "updates payment pointer" do
          post admin_settings_general_settings_path, params: {
            settings_general: { payment_pointer: "$pay.yo" },
            confirmation: confirmation_message
          }
          expect(Settings::General.payment_pointer).to eq("$pay.yo")
        end

        it "updates stripe configs" do
          post admin_settings_general_settings_path, params: {
            settings_general: {
              stripe_api_key: "sk_live_yo",
              stripe_publishable_key: "pk_live_haha"
            },
            confirmation: confirmation_message
          }
          expect(Settings::General.stripe_api_key).to eq("sk_live_yo")
          expect(Settings::General.stripe_publishable_key).to eq("pk_live_haha")
        end
      end

      describe "Newsletter" do
        it "updates mailchimp_api_key" do
          post admin_settings_general_settings_path, params: {
            settings_general: { mailchimp_api_key: "abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.mailchimp_api_key).to eq("abc")
        end

        it "updates mailchimp_newsletter_id" do
          post admin_settings_general_settings_path, params: {
            settings_general: { mailchimp_newsletter_id: "abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.mailchimp_newsletter_id).to eq("abc")
        end

        it "updates mailchimp_sustaining_members_id" do
          post admin_settings_general_settings_path, params: {
            settings_general: { mailchimp_sustaining_members_id: "abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.mailchimp_sustaining_members_id).to eq("abc")
        end

        it "updates mailchimp_tag_moderators_id" do
          post admin_settings_general_settings_path, params: {
            settings_general: { mailchimp_tag_moderators_id: "abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.mailchimp_tag_moderators_id).to eq("abc")
        end

        it "updates mailchimp_community_moderators_id" do
          post admin_settings_general_settings_path, params: {
            settings_general: { mailchimp_community_moderators_id: "abc" },
            confirmation: confirmation_message
          }
          expect(Settings::General.mailchimp_community_moderators_id).to eq("abc")
        end
      end

      describe "Onboarding" do
        it "updates onboarding_background_image" do
          expected_image_url = "https://dummyimage.com/300x300.png"
          post admin_settings_general_settings_path, params: {
            settings_general:
            { onboarding_background_image: expected_image_url },
            confirmation: confirmation_message
          }
          expect(Settings::General.onboarding_background_image).to eq(expected_image_url)
        end

        it "removes space suggested_tags" do
          post admin_settings_general_settings_path, params: {
            settings_general: { suggested_tags: "hey, haha,hoho, bobo fofo" },
            confirmation: confirmation_message
          }
          expect(Settings::General.suggested_tags).to eq(%w[hey haha hoho bobofofo])
        end

        it "downcases suggested_tags" do
          post admin_settings_general_settings_path, params: {
            settings_general: { suggested_tags: "hey, haha,hoHo, Bobo Fofo" },
            confirmation: confirmation_message
          }
          expect(Settings::General.suggested_tags).to eq(%w[hey haha hoho bobofofo])
        end

        it "removes space suggested_users" do
          post admin_settings_general_settings_path, params: {
            settings_general: {
              suggested_users: "piglet, tigger,eeyore, Christopher Robin, kanga,roo"
            },
            confirmation: confirmation_message
          }
          expect(Settings::General.suggested_users).to eq(%w[piglet tigger eeyore christopherrobin kanga roo])
        end

        it "downcases suggested_users" do
          post admin_settings_general_settings_path, params: {
            settings_general: {
              suggested_users: "piglet, tigger,EEYORE, Christopher Robin, KANGA,RoO"
            },
            confirmation: confirmation_message
          }
          expect(Settings::General.suggested_users).to eq(%w[piglet tigger eeyore christopherrobin kanga roo])
        end

        it "updates prefer_manual_suggested_users to true" do
          prefer_manual = true
          post admin_settings_general_settings_path, params: {
            settings_general: { prefer_manual_suggested_users: prefer_manual },
            confirmation: confirmation_message
          }
          expect(Settings::General.prefer_manual_suggested_users).to eq(prefer_manual)
        end

        it "updates prefer_manual_suggested_users to false" do
          prefer_manual = false
          post admin_settings_general_settings_path, params: {
            settings_general: { prefer_manual_suggested_users: prefer_manual },
            confirmation: confirmation_message
          }
          expect(Settings::General.prefer_manual_suggested_users).to eq(prefer_manual)
        end
      end

      describe "Rate Limits and spam" do
        it "updates follow_count_daily" do
          default_value = Settings::RateLimit.get_default(:follow_count_daily)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { follow_count_daily: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :follow_count_daily).from(default_value).to(3)
        end

        it "updates comment_creation" do
          default_value = Settings::RateLimit.get_default(:comment_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { comment_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :comment_creation).from(default_value).to(3)
        end

        it "updates mention_creation" do
          default_value = Settings::RateLimit.get_default(:mention_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { mention_creation: 10 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :mention_creation).from(default_value).to(10)
        end

        it "updates published_article_creation" do
          default_value = Settings::RateLimit.get_default(:published_article_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { published_article_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :published_article_creation).from(default_value).to(3)
        end

        it "updates published_article_antispam_creation" do
          default_value = Settings::RateLimit.get_default(:published_article_antispam_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { published_article_antispam_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :published_article_antispam_creation).from(default_value).to(3)
        end

        it "updates organization_creation" do
          default_value = Settings::RateLimit.get_default(:organization_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { organization_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :organization_creation).from(default_value).to(3)
        end

        it "updates image_upload" do
          default_value = Settings::RateLimit.get_default(:image_upload)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { image_upload: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :image_upload).from(default_value).to(3)
        end

        it "updates email_recipient" do
          default_value = Settings::RateLimit.get_default(:email_recipient)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { email_recipient: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :email_recipient).from(default_value).to(3)
        end

        it "updates user_subscription_creation" do
          default_value = Settings::RateLimit.get_default(:user_subscription_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { user_subscription_creation: 1 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :user_subscription_creation).from(default_value).to(1)
        end

        it "updates article_update" do
          default_value = Settings::RateLimit.get_default(:article_update)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { article_update: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :article_update).from(default_value).to(3)
        end

        it "updates user_update" do
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { user_update: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :user_update).to(3)
        end

        it "updates feedback_message_creation" do
          default_value = Settings::RateLimit.get_default(:feedback_message_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { feedback_message_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :feedback_message_creation).from(default_value).to(3)
        end

        it "updates listing_creation" do
          default_value = Settings::RateLimit.get_default(:listing_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { listing_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :listing_creation).from(default_value).to(3)
        end

        it "updates reaction_creation" do
          default_value = Settings::RateLimit.get_default(:reaction_creation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { reaction_creation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :reaction_creation).from(default_value).to(3)
        end

        it "updates send_email_confirmation" do
          default_value = Settings::RateLimit.get_default(:send_email_confirmation)
          expect do
            post admin_settings_rate_limits_path, params: {
              settings_rate_limit: { send_email_confirmation: 3 },
              confirmation: confirmation_message
            }
          end.to change(Settings::RateLimit, :send_email_confirmation).from(default_value).to(3)
        end

        it "updates spam_trigger_terms" do
          spam_trigger_terms = "hey, pokemon go hack"
          post admin_settings_rate_limits_path, params: {
            settings_rate_limit: { spam_trigger_terms: spam_trigger_terms },
            confirmation: confirmation_message
          }
          expect(Settings::RateLimit.spam_trigger_terms).to eq(["hey", "pokemon go hack"])
        end

        it "updates recaptcha_site_key and recaptcha_secret_key" do
          site_key = "hi-ho"
          secret_key = "lets-go"
          post admin_settings_authentications_path, params: {
            settings_authentication: { recaptcha_site_key: site_key, recaptcha_secret_key: secret_key },
            confirmation: confirmation_message
          }
          expect(Settings::Authentication.recaptcha_site_key).to eq site_key
          expect(Settings::Authentication.recaptcha_secret_key).to eq secret_key
        end
      end

      describe "Social Media" do
        it "updates social_media_handles" do
          expected_handle = { "facebook" => "tpd", "github" => "", "instagram" => "", "twitch" => "", "twitter" => "" }
          post admin_settings_general_settings_path, params: {
            settings_general: { social_media_handles: expected_handle },
            confirmation: confirmation_message
          }
          expect(Settings::General.social_media_handles[:facebook]).to eq("tpd")
          expect(Settings::General.social_media_handles[:github]).to eq("")
        end

        describe "twitter_hashtag" do
          twitter_hashtag = "#DEVCommunity"
          params = {
            settings_general: { twitter_hashtag: twitter_hashtag }, confirmation: "Incorrect confirmation"
          }

          it "does not update the twitter hashtag without the correct confirmation text" do
            expect do
              post admin_settings_general_settings_path, params: params
            end.to raise_error ActionController::BadRequest
          end

          it "updates the twitter hashtag" do
            params["confirmation"] = confirmation_message
            post admin_settings_general_settings_path, params: params
            expect(Settings::General.twitter_hashtag.to_s).to eq twitter_hashtag
          end
        end
      end

      describe "Sponsors" do
        it "updates the sponsor_headline" do
          headline = "basic"
          post admin_settings_general_settings_path, params: {
            settings_general: { sponsor_headline: headline },
            confirmation: confirmation_message
          }
          expect(Settings::General.sponsor_headline).to eq(headline)
        end
      end

      describe "Tags" do
        it "removes space sidebar_tags" do
          post admin_settings_general_settings_path, params: {
            settings_general: { sidebar_tags: "hey, haha,hoho, bobo fofo" },
            confirmation: confirmation_message
          }
          expect(Settings::General.sidebar_tags).to eq(%w[hey haha hoho bobofofo])
        end

        it "downcases sidebar_tags" do
          post admin_settings_general_settings_path, params: {
            settings_general: { sidebar_tags: "hey, haha,hoHo, Bobo Fofo" },
            confirmation: confirmation_message
          }
          expect(Settings::General.sidebar_tags).to eq(%w[hey haha hoho bobofofo])
        end

        it "creates tags if they do not exist" do
          post admin_settings_general_settings_path, params: {
            settings_general: { sidebar_tags: "bobofogololo, spla, bla" },
            confirmation: confirmation_message
          }
          expect(Tag.find_by(name: "bobofogololo")).to be_valid
        end
      end

      describe "User Experience" do
        it "updates the feed_style" do
          feed_style = "basic"
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { feed_style: feed_style },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.feed_style).to eq(feed_style)
        end

        it "updates the feed_strategy" do
          feed_strategy = "optimized"
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { feed_strategy: feed_strategy },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.feed_strategy).to eq(feed_strategy)
        end

        it "updates the tag_feed_minimum_score" do
          tag_feed_minimum_score = 3
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { tag_feed_minimum_score: tag_feed_minimum_score },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.tag_feed_minimum_score).to eq(tag_feed_minimum_score)
        end

        it "updates the home_feed_minimum_score" do
          home_feed_minimum_score = 5
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { home_feed_minimum_score: home_feed_minimum_score },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.home_feed_minimum_score).to eq(home_feed_minimum_score)
        end

        it "updates the brand color if proper hex" do
          hex = "#0a0a0a" # dark enough
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { primary_brand_color_hex: hex },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.primary_brand_color_hex).to eq(hex)
        end

        it "does not update brand color if hex not contrasting enough" do
          hex = "#bd746f" # not dark enough
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { primary_brand_color_hex: hex },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.primary_brand_color_hex).not_to eq(hex)
        end

        it "does not update brand color if hex not a hex with proper format" do
          hex = "0a0a0a" # dark enough, but not proper format
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { primary_brand_color_hex: hex },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.primary_brand_color_hex).not_to eq(hex)
        end

        it "updates public to true" do
          is_public = true
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { public: is_public },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.public).to eq(is_public)
        end

        it "updates public to false" do
          allow(Settings::UserExperience).to receive(:public).and_return(false)
          is_public = false
          post admin_settings_user_experiences_path, params: {
            settings_user_experience: { public: is_public },
            confirmation: confirmation_message
          }
          expect(Settings::UserExperience.public).to eq(is_public)
        end
      end

      describe "Credits" do
        it "updates the credit prices", :aggregate_failures do
          original_prices = Settings::General.get_default(:credit_prices_in_cents)
          Settings::General.credit_prices_in_cents = original_prices

          Settings::General.credit_prices_in_cents.each_key do |size|
            new_prices = original_prices.merge(size => 123)
            expect do
              post admin_settings_general_settings_path, params: {
                settings_general: { credit_prices_in_cents: new_prices },
                confirmation: confirmation_message
              }
            end.to change { Settings::General.credit_prices_in_cents[size] }.from(original_prices[size.to_sym]).to(123)
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
