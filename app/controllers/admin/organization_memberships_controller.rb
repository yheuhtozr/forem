module Admin
  class OrganizationMembershipsController < Admin::ApplicationController
    layout "admin"

    ALLOWED_PARAMS = %i[user_id type_of_user organization_id].freeze

    def update
      organization_membership = OrganizationMembership.find(params[:id])

      respond_to do |format|
        format.html do
          if organization_membership.update(organization_membership_params_for_update)
            flash[:success] =
              I18n.t("admin.organization_memberships_controller.user_was_successfully_upda",
                    organization_membership_ty: organization_membership.type_of_user)
          else
            flash[:danger] = organization_membership.errors_as_sentence
          end

          redirect_to admin_user_path(organization_membership.user_id)
        end

        format.js do
          if organization_membership.update(organization_membership_params_for_update)
            message =
              I18n.t("admin.organization_memberships_controller.user_was_successfully_upda",
                    organization_membership_ty: organization_membership.type_of_user)
            render json: { result: message }, content_type: "application/json"
          else
            render json: { error: organization_membership.errors_as_sentence },
                   content_type: "application/json",
                   status: :unprocessable_entity
          end
        end
      end
    end

    def create
      organization_membership = OrganizationMembership.new(organization_membership_params_for_create)
      organization = Organization.find_by(id: organization_membership_params_for_create[:organization_id])

      respond_to do |format| # rubocop:disable Metrics/BlockLength
        format.html do
          if organization && organization_membership.save
            flash[:success] = I18n.t("admin.organization_memberships_controller.user_was_successfully_adde", organization_name: organization.name)
          elsif organization.blank?
            message = I18n.t("admin.organization_memberships_controller.organization_does_not_exis",
                            organization_membership_pa: organization_membership_params_for_create[:organization_id])
            flash[:danger] = message
          else
            flash[:danger] = organization_membership.errors_as_sentence
          end

          redirect_to admin_user_path(organization_membership.user_id)
        end

        format.js do
          if organization && organization_membership.save
            message = I18n.t("admin.organization_memberships_controller.user_was_successfully_adde",
                    organization_name: organization.name)
            render json: { result: message }, content_type: "application/json", status: :created
          elsif organization.blank?
            message = I18n.t("admin.organization_memberships_controller.organization_does_not_exis",
                             organization_membership_pa: organization_membership_params_for_create[:organization_id])
            render json: { error: message }, content_type: "application/json", status: :unprocessable_entity
          else
            render json: { error: organization_membership.errors_as_sentence },
                   content_type: "application/json",
                   status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      organization_membership = OrganizationMembership.find(params[:id])
      organization = organization_membership.organization

      respond_to do |format|
        format.html do
          if organization_membership.destroy
            flash[:success] =
            I18n.t("admin.organization_memberships_controller.user_was_successfully_remo",
                   organization_membership_or: organization.name)
          else
            flash[:danger] = I18n.t("admin.organization_memberships_controller.something_went_wrong_with",
              organization_membership_or: organization.name)
          end

          redirect_to admin_user_path(organization_membership.user_id)
        end

        format.js do
          if organization_membership.destroy
            message =
            I18n.t("admin.organization_memberships_controller.user_was_successfully_remo",
                   organization_membership_or: organization.name)
            render json: { result: message }, content_type: "application/json"
          else
            message =  I18n.t("admin.organization_memberships_controller.something_went_wrong_with",
              organization_membership_or: organization.name)
            render json: { error: message },
                   content_type: "application/json",
                   status: :internal_server_error
          end
        end
      end
    end

    private

    def organization_membership_params_for_create
      params.require(:organization_membership).permit(ALLOWED_PARAMS)
    end

    def organization_membership_params_for_update
      params.require(:organization_membership).permit(:type_of_user)
    end
  end
end
