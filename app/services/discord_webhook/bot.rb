module DiscordWebhook
  class Bot
    require "discordrb/webhooks"

    class << self
      def new_post(article)
        target.execute do |post|
          post.content = "Migdal の新着記事です"
          post.add_embed do |embed|
            embed.title = article.title
            embed.url = URL.url(article.path)
            embed.description = article.description
            embed.author = embed_author(article.user)
            embed.timestamp = article.published_at
          end
        end
      end

      def new_listing(listing)
        target.execute do |post|
          post.content = "Migdal の告知情報です"
          post.add_embed do |embed|
            embed.title = "[告知] #{listing.title}"
            embed.url = URL.url(listing.path)
            embed.description = ActionView::Base.full_sanitizer.sanitize(listing.processed_html)
              .truncate(100, separator: " ").tr("\n", " ").strip
            embed.author = embed_author(listing.user)
            embed.timestamp = listing.originally_published_at
          end
        end
      end

      private

      def target
        Discordrb::Webhooks::Client.new(url: ApplicationConfig["DISCORD_WEBHOOK_URL"])
      end

      def embed_author(user)
        Discordrb::Webhooks::EmbedAuthor.new(
          name: user.name,
          url: URL.url(user.path),
          icon_url: URL.url(user.profile_image_90),
        )
      end
    end
  end
end
