class NotifyMailer < ApplicationMailer
  has_history extra: lambda {
    {
      feedback_message_id: params[:feedback_message_id],
      utm_campaign: params[:email_type]
    }
  }, only: :feedback_message_resolution_email

  def new_reply_email
    @comment = params[:comment]
    @user = @comment.parent_user
    return if RateLimitChecker.new.limit_by_email_recipient_address(@user.email)

    @unsubscribe = generate_unsubscribe_token(@user.id, :email_comment_notifications)

    mail(to: @user.email,
         subject: I18n.t("mailers.notify_mailer.replied_to_your", comment_user_name: @comment.user.name,
                                                                  comment_parent_type: @comment.parent_type))
  end

  def new_follower_email
    follow = params[:follow]

    @user = follow.followable
    return if RateLimitChecker.new.limit_by_email_recipient_address(@user.email)

    @follower = follow.follower
    @unsubscribe = generate_unsubscribe_token(@user.id, :email_follower_notifications)

    mail(to: @user.email, subject: "#{@follower.name} #{subjects[__method__]}")
  end

  def new_mention_email
    @mention = params[:mention]
    @user = User.find(@mention.user_id)
    return if RateLimitChecker.new.limit_by_email_recipient_address(@user.email)

    @mentioner = User.find(@mention.mentionable.user_id)
    @mentionable = @mention.mentionable
    @mentionable_type = @mention.decorate.formatted_mentionable_type

    @unsubscribe = generate_unsubscribe_token(@user.id, :email_mention_notifications)

    mail(to: @user.email,
         subject: I18n.t("mailers.notify_mailer.just_mentioned_you_in_thei", mentioner_name: @mentioner.name,
                                                                             mentionable_type: @mentionable_type))
  end

  def unread_notifications_email
    @user = params[:user]
    return if RateLimitChecker.new.limit_by_email_recipient_address(@user.email)

    @unread_notifications_count = @user.notifications.unread.count
    @unsubscribe = generate_unsubscribe_token(@user.id, :email_unread_notifications)
    subject = I18n.t("mailers.notify_mailer.you_have_unread_notificat", count: @unread_notifications_count,
                                                                        community: Settings::Community.community_name)
    mail(to: @user.email, subject: subject)
  end

  def video_upload_complete_email
    @article = params[:article]
    @user = @article.user
    mail(to: @user.email, subject: I18n.t("mailers.notify_mailer.your_video_upload_is_compl"))
  end

  def new_badge_email
    @badge_achievement = params[:badge_achievement]
    @user = @badge_achievement.user
    @badge = @badge_achievement.badge
    @unsubscribe = generate_unsubscribe_token(@user.id, :email_badge_notifications)

    mail(to: @user.email, subject: I18n.t("mailers.notify_mailer.you_just_got_a_badge"))
  end

  def feedback_response_email
    mail(to: params[:email_to],
         subject: I18n.t("mailers.notify_mailer.thanks_for_your_report_on",
                         community: Settings::Community.community_name))
  end

  def feedback_message_resolution_email
    @user = User.find_by(email: params[:email_to])
    @email_body = params[:email_body]

    mail(to: params[:email_to], subject: params[:email_subject])
  end

  def user_contact_email
    @user = User.find(params[:user_id])
    @email_body = params[:email_body]

    mail(to: @user.email, subject: params[:email_subject])
  end

  def new_message_email
    @message = params[:message]
    @user = @message.direct_receiver
    subject = I18n.t("mailers.notify_mailer.just_messaged_you", message_user_name: @message.user.name)
    @unsubscribe = generate_unsubscribe_token(@user.id, :email_connect_messages)

    mail(to: @user.email, subject: subject)
  end

  def channel_invite_email
    @membership = params[:membership]
    @inviter = params[:inviter]

    subject = if @membership.role == "mod"
                I18n.t("mailers.notify_mailer.you_are_invited_to_the_cha",
                       channel: @membership.chat_channel.channel_name)
              else
                I18n.t("mailers.notify_mailer.you_are_invited_to_the_cha2",
                       channel: @membership.chat_channel.channel_name)
              end

    mail(to: @membership.user.email, subject: subject)
  end

  def account_deleted_email
    @name = params[:name]

    subject = I18n.t("mailers.notify_mailer.account_deletion_confirma", community: Settings::Community.community_name)
    mail(to: params[:email], subject: subject)
  end

  def organization_deleted_email
    @name = params[:name]
    @org_name = params[:org_name]

    subject = I18n.t("mailers.notify_mailer.organization_deletion_con", community: Settings::Community.community_name)
    mail(to: params[:email], subject: subject)
  end

  def account_deletion_requested_email
    user = params[:user]
    @name = user.name
    @token = params[:token]

    subject = I18n.t("mailers.notify_mailer.account_deletion_requeste", community: Settings::Community.community_name)
    mail(to: user.email, subject: subject)
  end

  def export_email
    attachment = params[:attachment]

    export_filename = "devto-export-#{Date.current.iso8601}.zip"
    attachments[export_filename] = attachment
    mail(to: params[:email], subject: I18n.t("mailers.notify_mailer.the_export_of_your_content"))
  end

  def tag_moderator_confirmation_email
    @user = params[:user]
    @tag = params[:tag]

    subject = I18n.t("mailers.notify_mailer.congrats_you_re_the_modera", tag_name: @tag.name)
    mail(to: @user.email, subject: subject)
  end

  def trusted_role_email
    @user = params[:user]

    subject = I18n.t("mailers.notify_mailer.congrats_you_re_now_a_trus",
                     community: Settings::Community.community_name)
    mail(to: @user.email, subject: subject)
  end

  def subjects
    {
      new_follower_email: I18n.t("mailers.notify_mailer.just_followed_you_on",
                                 community: Settings::Community.community_name).freeze
    }.freeze
  end
end
