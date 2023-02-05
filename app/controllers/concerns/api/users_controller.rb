module Api
  module UsersController
    extend ActiveSupport::Concern

    SHOW_ATTRIBUTES_FOR_SERIALIZATION = %i[
      id username name summary twitter_username github_username website_url
      location created_at profile_image registered
    ].freeze

    def show
      relation = User.joins(:profile).select(SHOW_ATTRIBUTES_FOR_SERIALIZATION)

      @user = if params[:id] == "by_username"
                relation.find_by!(username: params[:url])
              else
                relation.find(params[:id])
              end
      not_found unless @user.registered
    end

    def me
      render :show
    end

    def suspend
      authorize(@user, :toggle_suspension_status?)

      target_user = User.find(params[:id])
      suspend_params = { note_for_current_role: params[:note], user_status: "Suspended" }

      begin
        Moderator::ManageActivityAndRoles.handle_user_roles(admin: @user,
                                                            user: target_user,
                                                            user_params: suspend_params)

        payload = { action: "api_user_suspend", target_user_id: target_user.id }
        Audit::Logger.log(:admin_api, @user, payload)

        render status: :no_content
      rescue StandardError
        render json: {
          success: false,
          message: @user.errors_as_sentence
        }, status: :unprocessable_entity
      end
    end

    def unpublish
      authorize(@user, :unpublish_all_articles?)

      target_user = User.find(params[:id].to_i)

      Moderator::UnpublishAllArticlesWorker.perform_async(target_user.id, @user.id)

      note_content = params[:note].presence || "#{@user.username} requested unpublish all articles via API"

      Note.create(noteable: target_user, reason: "unpublish_all_articles",
                  content: note_content, author: @user)

      render status: :no_content
    end
  end
end
