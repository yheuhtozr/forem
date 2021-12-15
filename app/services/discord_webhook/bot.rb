module DiscordWebhook
  class Bot
    require "discordrb/webhooks"

    class << self
      def new_post(article)
        return unless ApplicationConfig["DISCORD_KIITA_HOOK_URL"]

        builder = Discordrb::Webhooks::Builder.new(content: "Migdal の新着記事です", embeds: [post_embed(article)])
        target.execute builder
        target(url: ApplicationConfig["DISCORD_KIITA_HOOK_URL"]).execute builder
      end

      def edited_post(article)
        return unless ApplicationConfig["DISCORD_KIITA_HOOK_URL"]

        target(url: ApplicationConfig["DISCORD_KIITA_HOOK_URL"]).execute do |post|
          post.content = "Migdal の記事が更新されました"
          post << post_embed(article)
        end
      end

      def new_listing(listing)
        return unless ApplicationConfig["DISCORD_WEBHOOK_URL"]

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

      def target(url: ApplicationConfig["DISCORD_WEBHOOK_URL"])
        Discordrb::Webhooks::Client.new(url: url)
      end

      def post_embed(article)
        Discordrb::Webhooks::Embed.new(
          title: article.title,
          url: URL.url(article.path),
          description: article.description,
          author: embed_author(article.user),
          timestamp: article.published_at,
        )
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
