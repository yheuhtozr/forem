module Users
  class CreateMascotAccount
    def self.call
      new.call
    end

    def self.mascot
      {
        email: "mascot@forem.com",
        username: "mascot",
        name: I18n.t("services.users.create_mascot_account.mascot"),
        profile_image: Settings::General.mascot_image_url,
        confirmed_at: Time.current,
        registered_at: Time.current,
        password: SecureRandom.hex
      }.freeze
    end

    def call
      raise I18n.t("services.users.create_mascot_account.mascot_already_set") if Settings::General.mascot_user_id

      mascot = User.create!(mascot_params)
      Settings::General.mascot_user_id = mascot.id
    end

    def mascot_params
      # Set the password_confirmation
      mascot.merge(password_confirmation: mascot[:password])
    end
  end
end
