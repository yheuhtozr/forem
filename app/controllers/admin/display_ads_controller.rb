module Admin
  class DisplayAdsController < Admin::ApplicationController
    layout "admin"

    after_action :bust_ad_caches, only: %i[create update destroy]

    def index
      @display_ads = DisplayAd.order(id: :desc)
        .joins(:organization)
        .includes([:organization])
        .page(params[:page]).per(50)

      return if params[:search].blank?

      @display_ads = @display_ads.where("organizations.name ILIKE :search", search: "%#{params[:search]}%")
    end

    def new
      @display_ad = DisplayAd.new
    end

    def edit
      @display_ad = DisplayAd.find(params[:id])
    end

    def create
      @display_ad = DisplayAd.new(display_ad_params)

      if @display_ad.save
        flash[:success] = I18n.t("admin.display_ads_controller.display_ad_has_been_create")
        redirect_to admin_display_ads_path
      else
        flash[:danger] = @display_ad.errors_as_sentence
        render :new
      end
    end

    def update
      @display_ad = DisplayAd.find(params[:id])

      if @display_ad.update(display_ad_params)
        flash[:success] = I18n.t("admin.display_ads_controller.display_ad_has_been_update")
        redirect_to admin_display_ads_path
      else
        flash[:danger] = @display_ad.errors_as_sentence
        render :edit
      end
    end

    def destroy
      @display_ad = DisplayAd.find(params[:id])

      if @display_ad.destroy
        flash[:success] = I18n.t("admin.display_ads_controller.display_ad_has_been_delete")
        redirect_to admin_display_ads_path
      else
        flash[:danger] = I18n.t("admin.display_ads_controller.something_went_wrong_with")
        render :edit
      end
    end

    private

    def display_ad_params
      params.permit(:organization_id, :body_markdown, :placement_area, :published, :approved)
    end

    def authorize_admin
      authorize DisplayAd, :access?, policy_class: InternalPolicy
    end

    def bust_ad_caches
      EdgeCache::BustSidebar.call
    end
  end
end
