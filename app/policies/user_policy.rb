class UserPolicy < ApplicationPolicy
  PERMITTED_ATTRIBUTES = %i[
    reaction_notifications
    available_for
    bg_color_hex
    config_font
    config_theme
    config_navbar
    current_password
    currently_hacking_on
    currently_learning
    display_announcements
    display_sponsors
    editor_version education email
    email_badge_notifications
    email_comment_notifications
    email_community_mod_newsletter
    email_connect_messages
    email_digest_periodic
    email_follower_notifications
    email_membership_newsletter
    email_mention_notifications
    email_newsletter email_public
    email_tag_mod_newsletter
    email_unread_notifications
    employer_name
    employer_url
    employment_title
    experience_level
    export_requested
    feed_mark_canonical
    feed_referential_link
    feed_url
    inbox_guidelines
    inbox_type
    location
    mobile_comment_notifications
    mod_roundrobin_notifications
    welcome_notifications
    mostly_work_with
    name
    password
    password_confirmation
    payment_pointer
    permit_adjacent_sponsors
    profile_image
    summary
    text_color_hex
    username
    website_url
  ].freeze

  def edit?
    current_user?
  end

  def onboarding_update?
    true
  end

  def onboarding_checkbox_update?
    true
  end

  def onboarding_notifications_checkbox_update?
    true
  end

  def update?
    current_user?
  end

  def destroy?
    current_user?
  end

  def confirm_destroy?
    current_user?
  end

  def full_delete?
    current_user?
  end

  def request_destroy?
    current_user?
  end

  def join_org?
    !user_suspended?
  end

  def leave_org?
    OrganizationMembership.exists?(user_id: user.id, organization_id: record.id)
  end

  def remove_identity?
    current_user?
  end

  def dashboard_show?
    current_user? || user_admin? || minimal_admin?
  end

  def moderation_routes?
    (user.has_role?(:trusted) || minimal_admin?) && !user.suspended?
  end

  def update_password?
    current_user?
  end

  def permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  private

  def not_self?
    user != record
  end

  def current_user?
    user == record
  end
end
