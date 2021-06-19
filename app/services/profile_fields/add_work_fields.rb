module ProfileFields
  class AddWorkFields
    include FieldDefinition

    group "Work" do
      field I18n.t("services.profile_fields.add_work_fields.education"), :text_field, display_area: "header"
      field I18n.t("services.profile_fields.add_work_fields.employer_name"), :text_field,
            placeholder: I18n.t("services.profile_fields.add_work_fields.acme_inc"), display_area: "header"
      field I18n.t("services.profile_fields.add_work_fields.employer_url"), :text_field,
            placeholder: I18n.t("services.profile_fields.add_work_fields.https_dev_com"), display_area: "settings_only"
      field I18n.t("services.profile_fields.add_work_fields.employment_title"), :text_field, placeholder: I18n.t("services.profile_fields.add_work_fields.junior_frontend_engineer"), display_area: "header" # rubocop:disable Layout/LineLength
    end
  end
end
