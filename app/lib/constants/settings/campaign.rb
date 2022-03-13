module Constants
  module Settings
    module Campaign
      DETAILS = {
        articles_expiry_time: {
          description: "Sets the expiry time for articles (in weeks) to be displayed in campaign sidebar",
          placeholder: ""
        },
        articles_require_approval: {
          description: "",
          placeholder: "Campaign stories show up on sidebar with approval?"
        },
        display_name: {
          description: "This text is displayed in reference to the campaign in titles, etc.",
          placeholder: "My great campaign"
        },
        call_to_action: {
          description: "This text populates the call to action button on the campaign sidebar",
          placeholder: "Share your project"
        },
        featured_tags: {
          description: "Posts with which tags will be featured in the campaign sidebar (comma separated, letters only)",
          placeholder: "List of campaign tags: comma separated, letters only e.g. shecoded,theycoded"
        },
        hero_html_variant_name: {
          description: "Hero HtmlVariant name",
          placeholder: ""
        },
        sidebar_enabled: {
          description: "",
          placeholder: "Campaign sidebar enabled or not"
        },
        sidebar_image: {
          description: ::Constants::Settings::General::IMAGE_PLACEHOLDER,
          placeholder: "Used at the top of the campaign sidebar"
        },
        url: {
          description: "https://url.com/lander",
          placeholder: "URL campaign sidebar image will link to"
        }
      end
    end
  end
end
