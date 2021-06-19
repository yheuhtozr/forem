module ProfileFields
  class AddBaseFields
    include FieldDefinition

    group "Basic" do
      field I18n.t("services.profile_fields.add_base_fields.display_email_on_profile"),
            :check_box,
            display_area: "settings_only"
      field I18n.t("services.profile_fields.add_base_fields.website_url"),
            :text_field,
            placeholder: I18n.t("services.profile_fields.add_base_fields.https_yoursite_com"),
            display_area: "header",
            show_in_onboarding: true
      field I18n.t("services.profile_fields.add_base_fields.summary"),
            :text_area,
            placeholder: I18n.t("services.profile_fields.add_base_fields.a_short_bio"),
            display_area: "header",
            show_in_onboarding: true
      field I18n.t("services.profile_fields.add_base_fields.location"),
            :text_field,
            placeholder: I18n.t("services.profile_fields.add_base_fields.halifax_nova_scotia"),
            display_area: "header",
            show_in_onboarding: true
    end
  end
end
