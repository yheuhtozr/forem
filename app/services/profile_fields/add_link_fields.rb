module ProfileFields
  class AddLinkFields
    include FieldDefinition

    group "Links" do
      field I18n.t("services.profile_fields.add_link_fields.facebook_url"), :text_field,
            placeholder: "https://facebook.com/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.youtube_url"), :text_field,
            placeholder: "https://www.youtube.com/channel/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.stackoverflow_url"), :text_field,
            placeholder: "https://stackoverflow.com/users/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.linkedin_url"), :text_field,
            placeholder: "https://www.linkedin.com/in/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.behance_url"), :text_field,
            placeholder: "https://www.behance.net/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.dribbble_url"), :text_field,
            placeholder: "https://dribbble.com/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.medium_url"), :text_field,
            placeholder: "https://medium.com/@...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.gitlab_url"), :text_field,
            placeholder: "https://gitlab.com/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.instagram_url"), :text_field,
            placeholder: "https://www.instagram.com/...", display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.mastodon_url"), :text_field, placeholder: "https://...",
                                                                                         display_area: "header"
      field I18n.t("services.profile_fields.add_link_fields.twitch_url"), :text_field,
            placeholder: "https://www.twitch.tv/...", display_area: "header"
    end
  end
end
