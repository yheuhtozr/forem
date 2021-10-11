module Admin
  class InvitationsController < Admin::ApplicationController
    layout "admin"

    def index
      @invitations = User.where(registered: false).page(params[:page]).per(50)
    end

    def new; end

    def create
      email = params.dig(:user, :email)
      name = params.dig(:user, :name)

      if User.exists?(email: email.downcase, registered: true)
        flash[:error] = I18n.t("admin.invitations_controller.invitation_was_not_sent_th", email: email)
        redirect_to admin_invitations_path
        return
      end

      username = "#{name.downcase.tr(' ', '_').gsub(/[^0-9a-z ]/i, '')}_#{rand(1000)}"
      User.invite!(email: email,
                   name: name,
                   username: username,
                   remote_profile_image_url: ::Users::ProfileImageGenerator.call,
                   registered: false)
      flash[:success] = I18n.t("admin.invitations_controller.the_invite_has_been_sent_t")
      redirect_to admin_invitations_path
    end

    def destroy
      @invitation = User.where(registered: false).find(params[:id])
      if @invitation.destroy
        flash[:success] = I18n.t("admin.invitations_controller.the_invitation_has_been_de")
      else
        flash[:danger] = @invitation.errors_as_sentence
      end
      redirect_to admin_invitations_path
    end
  end
end
