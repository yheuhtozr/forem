module ChatChannels
  class CreateWithUsers
    def initialize(
      users: [],
      channel_type: "direct",
      contrived_name: I18n.t("services.chat_channels.create_with_users.new_channel"),
      membership_role: "member"
    )
      @users = users
      @channel_type = channel_type
      @contrived_name = contrived_name
      @membership_role = membership_role
    end

    def self.call(...)
      new(...).call
    end

    def call
      raise I18n.t("services.chat_channels.create_with_users.invalid_direct_channel") if invalid_direct_channel?(users, channel_type) # rubocop:disable Layout/LineLength

      usernames = users.map(&:username).sort
      slug = if channel_type == "direct"
               usernames.join("/")
             else
               "#{contrived_name.to_s.parameterize}-#{rand(100_000).to_s(26)}"
             end

      channel = ChatChannels::FindOrCreate.call(channel_type, slug, verify_contrived_name(usernames))
      if channel_type == "direct"
        channel.add_users(users)
      else
        channel.invite_users(users: users, membership_role: membership_role)
      end
      channel
    end

    private

    attr_reader :users, :channel_type, :membership_role, :contrived_name

    def invalid_direct_channel?(users, channel_type)
      (users.size != 2 || users.map(&:id).uniq.count < 2) && channel_type == "direct"
    end

    def verify_contrived_name(usernames)
      if channel_type == "direct"
        I18n.t("services.chat_channels.create_with_users.direct_chat_between",
               usernames_join_and: usernames.join(" and "))
      else
        contrived_name
      end
    end
  end
end
