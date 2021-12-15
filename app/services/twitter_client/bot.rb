module TwitterClient
  # Twitter client (users twitter gem as a backend)
  class Bot
    class << self
      def tweet(status)
        target.update(status) if active?
      end

      def new_post(article)
        # because an article's title is max 128 chars, title + URL (t.co) never exceeds current Twitter char limit
        tweet "#{article.title} #{URL.url(article.path)}" if active?
      end

      private

      # def request
      #   Honeycomb.add_field("name", "twitter.client")
      #   yield
      # rescue Twitter::Error => e
      #   record_error(e)
      #   handle_error(e)
      # end

      # def record_error(exception)
      #   class_name = exception.class.name.demodulize

      #   Honeycomb.add_field("twitter.result", "error")
      #   Honeycomb.add_field("twitter.error", class_name)
      #   ForemStatsClient.increment(
      #     "twitter.errors",
      #     tags: ["error:#{class_name}", "message:#{exception.message}"],
      #   )
      # end

      # def handle_error(exception)
      #   class_name = exception.class.name.demodulize

      #   # raise specific error if known, generic one if unknown
      #   error_class = "::TwitterClient::Errors::#{class_name}".safe_constantize
      #   raise error_class, exception.message if error_class

      #   error_class = if exception.class < Twitter::Error::ClientError
      #                   TwitterClient::Errors::ClientError
      #                 elsif exception.class < Twitter::Error::ServerError
      #                   TwitterClient::Errors::ServerError
      #                 else
      #                   TwitterClient::Errors::Error
      #                 end

      #   raise error_class, exception.message
      # end

      def target
        Twitter::REST::Client.new(
          consumer_key: ApplicationConfig["TWITTER_BOT_API_KEY"],
          consumer_secret: ApplicationConfig["TWITTER_BOT_API_SECRET"],
          access_token: ApplicationConfig["TWITTER_BOT_ACCESS_TOKEN"],
          access_token_secret: ApplicationConfig["TWITTER_BOT_ACCESS_SECRET"],
          user_agent: "TwitterRubyGem/#{Twitter::Version} (#{URL.url})",
          timeouts: {
            connect: 5,
            read: 5,
            write: 5
          },
        )
      end

      def active?
        ApplicationConfig["TWITTER_BOT_API_KEY"] &&
          ApplicationConfig["TWITTER_BOT_API_SECRET"] &&
          ApplicationConfig["TWITTER_BOT_ACCESS_TOKEN"] &&
          ApplicationConfig["TWITTER_BOT_ACCESS_SECRET"]
      end
    end
  end
end
