module Admin
  class UsersController < Admin::ApplicationController
    layout "admin"
    using StringToBoolean

    USER_ALLOWED_PARAMS = %i[
      new_note note_for_current_role user_status
      merge_user_id add_credits remove_credits
      add_org_credits remove_org_credits
      organization_id identity_id
    ].freeze

    EMAIL_ALLOWED_PARAMS = %i[
      email_subject
      email_body
    ].freeze

    after_action only: %i[update user_status banish full_delete merge] do
      Audit::Logger.log(:moderator, current_user, params.dup)
    end

    def index
      @users = Admin::UsersQuery.call(
        options: params.permit(:role, :search),
      ).page(params[:page]).per(50)
    end

    def edit
      @user = User.find(params[:id])
      @notes = @user.notes.order(created_at: :desc).limit(10).load
      set_feedback_messages
      set_related_reactions
    end

    def show
      @user = User.find(params[:id])
      @organizations = @user.organizations.order(:name)
      @notes = @user.notes.order(created_at: :desc).limit(10)
      @organization_memberships = @user.organization_memberships
        .joins(:organization)
        .order("organizations.name" => :asc)
        .includes(:organization)
      @last_email_verification_date = @user.email_authorizations
        .where.not(verified_at: nil)
        .order(created_at: :desc).first&.verified_at || I18n.t("admin.users_controller.never")
    end

    def update
      @user = User.find(params[:id])

      # TODO: [@rhymes] in the new Admin Member view this logic has been moved
      # to Admin::Users::Tools::CreditsController and Admin::Users::Tools::NotesController#create.
      # It can eventually be removed when we transition away from the old Admin UI
      Credits::Manage.call(@user, user_params)
      add_note if user_params[:new_note]

      redirect_to admin_user_path(params[:id])
    end

    def destroy
      role = params[:role].to_sym
      resource_type = params[:resource_type]

      @user = User.find(params[:user_id])

      response = ::Users::RemoveRole.call(user: @user,
                                          role: role,
                                          resource_type: resource_type,
                                          admin: current_user)
      if response.success
        flash[:success] =
          I18n.t("admin.users_controller.role_has_been_successfully",
                 role_to_s_humanize_titleca: role.to_s.humanize.titlecase)
      else
        flash[:danger] = response.error_message
      end
      redirect_to edit_admin_user_path(@user.id)
    end

    def user_status
      @user = User.find(params[:id])
      begin
        Moderator::ManageActivityAndRoles.handle_user_roles(admin: current_user, user: @user, user_params: user_params)
        flash[:success] = I18n.t("admin.users_controller.user_has_been_updated")
      rescue StandardError => e
        flash[:danger] = e.message
      end
      redirect_to edit_admin_user_path(@user.id)
    end

    def export_data
      user = User.find(params[:id])
      send_to_admin = params[:send_to_admin].to_boolean
      if send_to_admin
        email = ::ForemInstance.email
        receiver = "admin"
      else
        email = user.email
        receiver = "user"
      end
      ExportContentWorker.perform_async(user.id, email)
      flash[:success] = I18n.t("admin.users_controller.data_exported_to_the_the_j", receiver: receiver)
      redirect_to edit_admin_user_path(user.id)
    end

    def banish
      Moderator::BanishUserWorker.perform_async(current_user.id, params[:id].to_i)
      flash[:success] = I18n.t("admin.users_controller.this_user_is_being_banishe")
      redirect_to edit_admin_user_path(params[:id])
    end

    def full_delete
      @user = User.find(params[:id])
      begin
        Moderator::DeleteUser.call(user: @user)
        link = helpers.tag.a(I18n.t("admin.users_controller.the_page"), href: admin_users_gdpr_delete_requests_path,
                                                                        data: { "no-instant" => true })
        flash[:success] = I18n.t("admin.users_controller.full_delete_html",
                                 user: @user.username,
                                 email: @user.email.presence || I18n.t("admin.users_controller.no_email"),
                                 id: @user.id,
                                 the_page: link)
      rescue StandardError => e
        flash[:danger] = e.message
      end
      redirect_to admin_users_path
    end

    def merge
      @user = User.find(params[:id])
      begin
        Moderator::MergeUser.call(admin: current_user, keep_user: @user, delete_user_id: user_params["merge_user_id"])
      rescue StandardError => e
        flash[:danger] = e.message
      end

      redirect_to edit_admin_user_path(@user.id)
    end

    def remove_identity
      identity = Identity.find(user_params[:identity_id])
      @user = identity.user

      begin
        identity.destroy

        @user.update("#{identity.provider}_username" => nil)

        # GitHub repositories are tied with the existence of the GitHub identity
        # as we use the user's GitHub token to fetch them from the API.
        # We should delete them when a user unlinks their GitHub account.
        @user.github_repos.destroy_all if identity.provider.to_sym == :github

        flash[:success] =
          I18n.t("admin.users_controller.the_identity_was_successfu",
                 identity_provider_capitali: identity.provider.capitalize)
      rescue StandardError => e
        flash[:danger] = e.message
      end
      redirect_to edit_admin_user_path(@user.id)
    end

    # NOTE: [@rhymes] This should be eventually moved in Admin::Users::Tools::EmailsController
    # once the HTML response isn't required anymore
    def send_email
      email_params = {
        email_body: send_email_params[:email_body],
        email_subject: send_email_params[:email_subject],
        user_id: params[:id]
      }

      if NotifyMailer.with(email_params).user_contact_email.deliver_now
        respond_to do |format|
          message = "Email sent!"

          format.html do
            flash[:success] = message
            redirect_back(fallback_location: admin_users_path)
          end

          format.js { render json: { result: message }, content_type: "application/json" }
        end
      else
        flash[:danger] = I18n.t("admin.users_controller.email_failed_to_send")
      end
    end

    # NOTE: [@rhymes] This should be eventually moved in Admin::Users::Tools::EmailsController
    # once the HTML response isn't required anymore
    def verify_email_ownership
      if VerificationMailer.with(user_id: params[:user_id]).account_ownership_verification_email.deliver_now
        flash[:success] = I18n.t("admin.users_controller.email_verification_mailer")
        redirect_back(fallback_location: admin_users_path)
      else
        flash[:danger] = I18n.t("admin.users_controller.email_failed_to_send")
      end
    end

    def unlock_access
      @user = User.find(params[:id])
      @user.unlock_access!
      flash[:success] = I18n.t("admin.users_controller.unlocked_user_account")
      redirect_to admin_user_path(@user)
    end

    private

    def add_note
      Note.create(
        author_id: current_user.id,
        noteable_id: @user.id,
        noteable_type: "User",
        reason: "misc_note",
        content: user_params[:new_note],
      )
    end

    def set_feedback_messages
      @related_reports = FeedbackMessage.where(id: @user.reporter_feedback_messages.ids)
        .or(FeedbackMessage.where(id: @user.affected_feedback_messages.ids))
        .or(FeedbackMessage.where(id: @user.offender_feedback_messages.ids))
        .order(created_at: :desc).limit(15)
    end

    def set_related_reactions
      user_article_ids = @user.articles.ids
      user_comment_ids = @user.comments.ids
      @related_vomit_reactions =
        Reaction.where(reactable_type: "Comment", reactable_id: user_comment_ids, category: "vomit")
          .or(Reaction.where(reactable_type: "Article", reactable_id: user_article_ids, category: "vomit"))
          .or(Reaction.where(reactable_type: "User", user_id: @user.id, category: "vomit"))
          .includes(:reactable)
          .order(created_at: :desc).limit(15)
    end

    def user_params
      params.require(:user).permit(USER_ALLOWED_PARAMS)
    end

    def send_email_params
      params.require(EMAIL_ALLOWED_PARAMS)
      params.permit(EMAIL_ALLOWED_PARAMS)
    end
  end
end
