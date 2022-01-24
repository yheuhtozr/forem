# rubocop:disable Metrics/BlockLength
namespace :navigation_links do
  def image_path(*paths)
    File.read(Rails.root.join("app/assets/images/#{paths.join('/')}")).freeze
  end

  def twemoji_path(name)
    image_path("twemoji", name)
  end

  reading_icon = twemoji_path("drawer.svg")
  contact_icon = twemoji_path("contact.svg")
  thumb_up_icon = twemoji_path("thumb-up.svg")
  smart_icon = twemoji_path("smart.svg")
  look_icon = twemoji_path("look.svg")
  listing_icon = twemoji_path("listing.svg")
  mic_icon = twemoji_path("mic.svg")
  camera_icon = twemoji_path("camera.svg")
  tag_icon = twemoji_path("tag.svg")
  bulb_icon = twemoji_path("bulb.svg")
  shopping_icon = twemoji_path("shopping.svg")
  heart_icon = twemoji_path("heart.svg")
  rainbowdev = image_path("rainbowdev.svg")

  def perform_create_of_navigation_links?
    # Someone really wants this
    return true if ApplicationConfig["CREATE_NAVIGATION_LINKS"]

    # This logic echoes the InternalPolicy behavior which is used in the
    # Admin::AppliciationController.
    return false if User.with_any_role(*Authorizer::RoleBasedQueries::ANY_ADMIN_ROLES).any?

    true
  end

  desc "Create navigation links for new forem"
  task create: :environment do
    if perform_create_of_navigation_links?
      puts "Creating navigation links"
      # [@jeremyf] I went ahead and atomized these tasks so we _could_ call them individually if
      #            desired.  I did not add descriptions so those tasks will not show up in the task
      #            list.
      Rake::Task["navigation_links:find_or_create:readinglist"].invoke
      Rake::Task["navigation_links:find_or_create:contact"].invoke
      Rake::Task["navigation_links:find_or_create:code_of_conduct"].invoke
      Rake::Task["navigation_links:find_or_create:privacy"].invoke
      Rake::Task["navigation_links:find_or_create:terms"].invoke
    else
      # Adding just a bit of logging
      Rails.logger.info "Skipping creation of navigation links"
    end
  end

  namespace :find_or_create do
    task readinglist: :environment do
      NavigationLink.where(url: "/readinglist").first_or_create(
        name: "Reading List",
        url: URL.url("readinglist"),
        icon: reading_icon,
        display_only_when_signed_in: true,
        position: 0,
        section: :default,
      )
    end

    task contact: :environment do
      NavigationLink.where(url: "/contact").first_or_create(
        name: "Contact",
        url: URL.url("contact"),
        icon: contact_icon,
        display_only_when_signed_in: false,
        position: 1,
        section: :default,
      )
    end

    task code_of_conduct: :environment do
      NavigationLink.where(url: "/code-of-conduct").first_or_create(
        name: "Code of Conduct",
        url: URL.url(Page::CODE_OF_CONDUCT_SLUG),
        icon: thumb_up_icon,
        display_only_when_signed_in: false,
        position: 0,
        section: :other,
      )
    end

    task privacy: :environment do
      NavigationLink.where(url: "/privacy").first_or_create(
        name: "Privacy Policy",
        url: URL.url(Page::PRIVACY_SLUG),
        icon: smart_icon,
        display_only_when_signed_in: false,
        position: 1,
        section: :other,
      )
    end

    task terms: :environment do
      NavigationLink.where(url: "/terms").first_or_create(
        name: "Terms of Use",
        url: URL.url(Page::TERMS_SLUG),
        icon: look_icon,
        display_only_when_signed_in: false,
        position: 2,
        section: :other,
      )
    end
  end

  desc "Update DEV's navigation_links"
  task update: :environment do
    protocol = ApplicationConfig["APP_PROTOCOL"].freeze
    domain = Rails.application&.initialized? ? Settings::General.app_domain : ApplicationConfig["APP_DOMAIN"]
    base_url = "#{protocol}#{domain}".freeze

    NavigationLink.where(url: "#{base_url}/readinglist").first_or_create(
      name: "Reading List",
      icon: reading_icon,
      display_only_when_signed_in: true,
      position: 0,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/listings").first_or_create(
      name: "Listings",
      icon: listing_icon,
      display_only_when_signed_in: false,
      position: 1,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/pod").first_or_create(
      name: "Podcasts",
      icon: mic_icon,
      display_only_when_signed_in: false,
      position: 2,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/videos").first_or_create(
      name: "Videos",
      icon: camera_icon,
      display_only_when_signed_in: false,
      position: 3,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/tags").first_or_create(
      name: "Tags",
      icon: tag_icon,
      display_only_when_signed_in: false,
      position: 4,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/code-of-conduct").first_or_create(
      name: "Code of Conduct",
      icon: thumb_up_icon,
      display_only_when_signed_in: false,
      position: 0,
      section: :other,
    )
    NavigationLink.where(url: "#{base_url}/faq").first_or_create(
      name: "FAQ",
      icon: bulb_icon,
      display_only_when_signed_in: false,
      position: 5,
      section: :default,
    )
    NavigationLink.where(url: "https://shop.dev.to/").first_or_create(
      name: "DEV Shop",
      icon: shopping_icon,
      display_only_when_signed_in: false,
      position: 6,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/sponsors").first_or_create(
      name: "Sponsors",
      icon: heart_icon,
      display_only_when_signed_in: false,
      position: 7,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/about").first_or_create(
      name: "About",
      icon: rainbowdev,
      display_only_when_signed_in: false,
      position: 8,
      section: :default,
    )
    NavigationLink.where(url: "#{base_url}/privacy").first_or_create(
      name: "Privacy Policy",
      icon: smart_icon,
      display_only_when_signed_in: false,
      position: 1,
      section: :other,
    )
    NavigationLink.where(url: "#{base_url}/terms").first_or_create(
      name: "Terms of Use",
      icon: look_icon,
      display_only_when_signed_in: false,
      position: 2,
      section: :other,
    )
    NavigationLink.where(url: "#{base_url}/contact").first_or_create(
      name: "Contact",
      icon: contact_icon,
      display_only_when_signed_in: false,
      position: 9,
      section: :default,
    )
  end
end
# rubocop:enable Metrics/BlockLength
