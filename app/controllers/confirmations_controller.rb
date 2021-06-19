class ConfirmationsController < Devise::ConfirmationsController
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    resource.errors.clear # Don't leak user information, like paranoid mode.

    message = I18n.t("confirmations_controller.email_sent", email: Settings::General.email_addresses[:default])
    flash.now[:global_notice] = message
    render :new
  end
end
