module TwitterClient
  # Use Twitter v2 API (cf. https://hawksnowlog.blogspot.com/2023/05/ruby-sample-code-for-twitterv2-api.html)
  class Bot
    require "json"
    # require "typhoeus"
    # require "oauth"
    require "oauth/request_proxy/typhoeus_request"

    class << self
      def options(payload)
        {
          method: :post,
          headers: {
            "User-Agent": "MigdalTwitterV2Bot",
            "content-type": "application/json"
          },
          body: JSON.dump(payload)
        }
      end

      def consumer
        OAuth::Consumer.new(_consumer_key, _consumer_secret, { site: "https://api.twitter.com", debug_output: false })
      end

      def access_token
        OAuth::AccessToken.new(consumer, _access_token, _access_token_secret)
      end

      def post_tweet(url, oauth_params, payload)
        request = Typhoeus::Request.new(url, options(payload))
        oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(request_uri: url))
        request.options[:headers][:Authorization] = oauth_helper.header

        request.on_complete do |response|
          if response.failure?
            raise TwitterClient::Errors::Error, response.body
          end
        end
        request.run
      end

      def tweet(status)
        return unless active?

        payload = { text: status }
        oauth_params = {
          consumer: consumer,
          token: access_token
        }
        post_tweet(_endpoint, oauth_params, payload)
      end

      def new_post(article)
        # because an article's title is max 128 chars, title + URL (t.co) never exceeds current Twitter char limit
        tweet "#{article.title} #{URL.url(article.path)}" if active?
      end

      private

      def active?
        (Settings::Authentication.twitter_key.presence || ApplicationConfig["TWITTER_KEY"]) &&
          (Settings::Authentication.twitter_secret.presence || ApplicationConfig["TWITTER_SECRET"]) &&
          ApplicationConfig["TWITTER_BOT_ACCESS_TOKEN"] &&
          ApplicationConfig["TWITTER_BOT_ACCESS_SECRET"]
      end

      def _consumer_key
        Settings::Authentication.twitter_key.presence || ApplicationConfig["TWITTER_KEY"]
      end

      def _consumer_secret
        Settings::Authentication.twitter_secret.presence || ApplicationConfig["TWITTER_SECRET"]
      end

      def _access_token
        ApplicationConfig["TWITTER_BOT_ACCESS_TOKEN"]
      end

      def _access_token_secret
        ApplicationConfig["TWITTER_BOT_ACCESS_SECRET"]
      end

      def _endpoint
        "https://api.twitter.com/2/tweets"
      end
    end
  end
end
