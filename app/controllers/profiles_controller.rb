class ProfilesController < ApplicationController
  before_action :authenticate_user!
  ALLOWED_USER_PARAMS = %i[name email username profile_image].freeze

  def update
    update_result = Profiles::Update.call(current_user, update_params)
    if update_result.success?
      flash[:settings_notice] = I18n.t("profiles_controller.your_profile_has_been_upda")
      redirect_to user_settings_path
    else
      @user = current_user
      @tab = "profile"
      flash[:error] = I18n.t("common.error", errors: update_result.errors_as_sentence)
      render template: "users/edit", locals: {
        user: update_params[:user],
        profile: update_params[:profile]
      }
    end
  end

  private

  def update_params
    params.permit(profile: Profile.attributes + Profile.static_fields, user: ALLOWED_USER_PARAMS)
  end
end
