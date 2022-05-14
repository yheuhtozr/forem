class OgpGeneration
  require "fileutils"
  require "playwright"

  ROUTES = %w[uploads articles ogp].freeze
  CACHE_PATH = "cache.html".freeze
  IMAGE_PATH = "image.png".freeze
  DIR_PATH = Rails.root.join "public", *ROUTES

  def initialize(html, id)
    @exec = Playwright.create playwright_cli_executable_path: "./node_modules/.bin/playwright"
    @html = html
    @id = id
    @dir = DIR_PATH.join @id.to_s
  end

  def generate
    cache = @dir.join(CACHE_PATH)
    return if File.exist?(cache) && @html == File.read(cache, mode: "r:utf-8")

    FileUtils.mkpath @dir
    generate!
    File.open(cache, "w:utf-8") { |f| f.write @html }
  end

  def generate!
    @exec.playwright.chromium.launch do |browser|
      page = browser.new_page viewport: { width: 1200, height: 630 }
      page.default_timeout = 100_000
      page.goto URL.url("social_previews/article/#{@id}")
      page.wait_for_function "() => document.fonts.check('28px IBM Plex Sans JP')" # check if a used webfont loaded
      page.screenshot path: @dir.join(IMAGE_PATH)
    end
  ensure
    @exec.stop
  end

  def url
    generate
    path = @dir.join(IMAGE_PATH)
    File.exist?(path) ? URL.url("#{ROUTES.join '/'}/#{@id}/#{IMAGE_PATH}") : Settings::General.main_social_image.to_s
  end
end
