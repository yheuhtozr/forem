module Admin
  class BillboardsController < Admin::ApplicationController
    layout "admin"

    after_action :bust_ad_caches, only: %i[create update destroy]

    def index
      @billboards = DisplayAd.order(id: :desc)
        .page(params[:page]).per(50)

      return if params[:search].blank?

      @billboards = @billboards.search_ads(params[:search])
    end

    def new
      @billboard = DisplayAd.new
    end

    def edit
      @billboard = DisplayAd.find(params[:id])
    end

    def create
      @billboard = DisplayAd.new(billboard_params)
      @billboard.creator = current_user

      if @billboard.save
        flash[:success] = I18n.t("admin.billboards_controller.created")
        redirect_to edit_admin_billboard_path(@billboard.id)
      else
        flash[:danger] = @billboard.errors_as_sentence
        render :new
      end
    end

    def update
      @billboard = DisplayAd.find(params[:id])

      if @billboard.update(billboard_params)
        flash[:success] = I18n.t("admin.billboards_controller.updated")
        redirect_to edit_admin_billboard_path(params[:id])
      else
        flash[:danger] = @billboard.errors_as_sentence
        render :edit
      end
    end

    def destroy
      @billboard = DisplayAd.find(params[:id])

      if @billboard.destroy
        render json: { message: I18n.t("admin.billboards_controller.deleted") }, status: :ok
      else
        render json: { error: I18n.t("admin.billboards_controller.wrong") }, status: :unprocessable_entity
      end
    end

    private

    def billboard_params
      params.permit(:organization_id, :body_markdown, :placement_area, :target_geolocations,
                    :published, :approved, :name, :display_to, :tag_list, :type_of,
                    :exclude_article_ids, :audience_segment_id, :priority)
    end

    def authorize_admin
      authorize DisplayAd, :access?, policy_class: InternalPolicy
    end

    def bust_ad_caches
      EdgeCache::BustSidebar.call
    end
  end
end
