class OgpGeneration
  require "fileutils"
  require "playwright"
  require "singleton"

  include Singleton

  ROUTES = %w[uploads articles ogp].freeze
  CACHE_PATH = "cache.html".freeze
  IMAGE_PATH = "image.png".freeze
  DIR_PATH = Rails.public_path.join(*ROUTES).freeze

  def initialize
    @exec = Playwright.create playwright_cli_executable_path: "./node_modules/.bin/playwright"
  end

  def generate(html, id)
    dir = path_to id.to_s
    cache = dir.join(CACHE_PATH)
    return if File.exist?(cache) && html == File.read(cache, mode: "r:utf-8")

    FileUtils.mkpath dir
    generate! id
    File.open(cache, "w:utf-8") { |f| f.write html }
  end

  def generate!(id)
    dir = path_to id.to_s
    @exec.playwright.chromium.launch do |browser|
      page = browser.new_page viewport: { width: 1200, height: 630 }
      page.default_timeout = 100_000
      page.goto URL.url("social_previews/article/#{id}")
      page.wait_for_function "() => document.fonts.check('28px IBM Plex Sans JP')" # check if a used webfont loaded
      page.screenshot path: dir.join(IMAGE_PATH)
    end
  end

  def url(html, id)
    generate html, id
    path = path_to(id.to_s).join(IMAGE_PATH)
    File.exist?(path) ? URL.url("#{ROUTES.join '/'}/#{id}/#{IMAGE_PATH}") : Settings::General.main_social_image.to_s
  end

  private

  def path_to(id)
    DIR_PATH.join id.to_s
  end
end
