class ApiSecretsController < ApplicationController
  before_action :load_api_secret, only: :destroy
  after_action :verify_authorized

  def create
    authorize ApiSecret

    @secret = ApiSecret.new(permitted_attributes(ApiSecret))
    @secret.user_id = current_user.id

    if @secret.save
      flash[:notice] = I18n.t("api_secrets_controller.your_api_key_has_been_gene", secret_secret: @secret.secret)
    else
      flash[:error] = @secret.errors_as_sentence
    end

    redirect_back(fallback_location: root_path)
  end

  def destroy
    authorize @secret

    if @secret.destroy
      flash[:notice] = I18n.t("api_secrets_controller.your_api_key_has_been_revo")
    else
      flash[:error] =
        I18n.t("api_secrets_controller.an_error_occurred_please_t",
               settings_general_email_add: ForemInstance.email)
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def load_api_secret
    @secret = ApiSecret.find(destroy_params[:id])
  end

  def destroy_params
    params.permit(:id)
  end
end
