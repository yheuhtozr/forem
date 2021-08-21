module Admin
  class OrganizationMembershipsController < Admin::ApplicationController
    layout "admin"

    ALLOWED_PARAMS = %i[user_id type_of_user organization_id].freeze

    def update
      organization_membership = OrganizationMembership.find_by(id: params[:id])
      if organization_membership.update(organization_membership_params)
        flash[:success] =
          I18n.t("admin.organization_memberships_controller.user_was_successfully_upda",
                 organization_membership_ty: organization_membership.type_of_user)
      else
        flash[:danger] = organization_membership.errors.full_messages
      end
    end

    def create
      organization_membership = OrganizationMembership.new(organization_membership_params)
      organization = Organization.find_by(id: organization_membership_params[:organization_id])
      if organization && organization_membership.save
        flash[:success] =
          I18n.t("admin.organization_memberships_controller.user_was_successfully_adde",
                 organization_name: organization.name)
      elsif organization.blank?
        message = I18n.t("admin.organization_memberships_controller.organization_does_not_exis",
                         organization_membership_pa: organization_membership_params[:organization_id])
        flash[:danger] = message
      else
        flash[:danger] = organization_membership.errors.full_messages
      end
    end

    def destroy
      organization_membership = OrganizationMembership.find_by(id: params[:id])
      if organization_membership.destroy
        flash[:success] =
          I18n.t("admin.organization_memberships_controller.user_was_successfully_remo",
                 organization_membership_or: organization_membership.organization_id)
      else
        message = I18n.t("admin.organization_memberships_controller.something_went_wrong_with",
                         organization_membership_or: organization_membership.organization_id)
        flash[:danger] = message
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
