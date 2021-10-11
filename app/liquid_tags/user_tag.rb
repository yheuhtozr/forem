class UserTag < LiquidTagBase
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  PARTIAL = "users/liquid".freeze

  def initialize(_tag_name, user, _parse_context)
    super
    @user = parse_username_to_user(user.delete(" "))
    @follow_button = follow_button(@user)
    @user_colors = user_colors(@user)
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: {
        user: user_object_for_partial(@user),
        follow_button: @follow_button,
        user_colors: @user_colors,
        user_path: path_to_profile(@user)
      },
    )
  end

  private

  def parse_username_to_user(user)
    User.find_by(username: user, registered: true) || deleted_user
  end

  def path_to_profile(user)
    user == deleted_user ? nil : user.path
  end

  def user_object_for_partial(user)
    user == deleted_user ? user : user.decorate
  end
end

Liquid::Template.register_tag("user", UserTag)
