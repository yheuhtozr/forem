module ProfileFields
  class AddBrandingFields
    include FieldDefinition

    group "Branding" do
      field I18n.t("services.profile_fields.add_branding_fields.brand_color_1"),
            :color_field,
            placeholder: "#000000",
            description: I18n.t("services.profile_fields.add_branding_fields.used_for_backgrounds_borde"),
            display_area: "settings_only"
      field I18n.t("services.profile_fields.add_branding_fields.brand_color_2"),
            :color_field,
            placeholder: "#000000",
            description: I18n.t("services.profile_fields.add_branding_fields.used_for_texts_usually_put"),
            display_area: "settings_only"
    end
  end
end
