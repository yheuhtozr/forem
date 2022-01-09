class SpotifyTag < LiquidTagBase
  PARTIAL = "liquids/spotify".freeze
  URI_REGEXP = /spotify:(track|artist|playlist|album|episode|show):\w{22}/
  URI_PLAYLIST_REGEXP = /spotify:(user):([a-zA-Z0-9]+):playlist:\w{22}/ # legacy support
  TYPE_HEIGHT = {
    track: 80,
    user: 380,
    artist: 380,
    album: 380,
    playlist: 380,
    episode: 232,
    show: 232
  }.freeze

  def initialize(_tag_name, uri, _parse_context)
    super
    @parsed_uri = parse_uri(uri)
    @embed_link = generate_embed_link(@parsed_uri[0])
    @type = @parsed_uri[1] || @parsed_uri[2]
    @height = TYPE_HEIGHT[@type.to_sym]
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        embed_link: @embed_link,
        height: @height
      },
    )
  end

  private

  def parse_input(input)
    match = pattern_match_for(input, REGEXP_OPTIONS)
    raise StandardError, I18n.t("liquid_tags.spotify_tag.invalid_spotify_uri") unless match

  def raise_error
    msg = I18n.t("liquid_tags.spotify_tag.invalid_spotify_link_be_su")
    raise StandardError, msg
  end
end

Liquid::Template.register_tag("spotify", SpotifyTag)
