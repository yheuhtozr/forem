module Admin
  class PagesController < Admin::ApplicationController
    layout "admin"

    PAGE_ALLOWED_PARAMS = %i[
      title slug body_markdown body_html body_json description template
      is_top_level_path social_image landing_page
    ].freeze

    def index
      @pages = Page.all.order(created_at: :desc)
      @code_of_conduct = Page.find_by(slug: "code-of-conduct")
      @privacy = Page.find_by(slug: "privacy")
      @terms = Page.find_by(slug: "terms")
    end

    def new
      @landing_page = Page.landing_page

      if (slug = params[:slug])
        prepopulate_new_form(slug)
      else
        @page = Page.new
      end
    end

    def edit
      @page = Page.find(params[:id])
      @landing_page = Page.landing_page
    end

    def update
      @page = Page.find(params[:id])
      @page.assign_attributes(page_params)
      if @page.valid?
        @page.update!(page_params)
        flash[:success] = I18n.t("admin.pages_controller.page_has_been_successfully")
        redirect_to admin_pages_path
      else
        flash.now[:error] = @page.errors_as_sentence
        render :edit
      end
    end

    def create
      @page = Page.new(page_params)
      if @page.valid?
        @page.save!
        flash[:success] = I18n.t("admin.pages_controller.page_has_been_successfully2")
        redirect_to admin_pages_path
      else
        flash.now[:error] = @page.errors_as_sentence
        render :new
      end
    end

    def destroy
      @page = Page.find(params[:id])
      @page.destroy
      flash[:success] = I18n.t("admin.pages_controller.page_has_been_successfully3")
      redirect_to admin_pages_path
    end

    private

    def page_params
      params.require(:page).permit(PAGE_ALLOWED_PARAMS)
    end

    def prepopulate_new_form(slug)
      html = view_context.render partial: "pages/coc_text",
                                 locals: {
                                   community_name: view_context.community_name,
                                   email_link: view_context.email_link
                                 }
      @page = case slug
              when "code-of-conduct"
                Page.new(
                  slug: slug,
                  body_html: html,
                  title: I18n.t("admin.pages_controller.code_of_conduct"),
                  description: I18n.t("admin.pages_controller.a_page_that_describes_how"),
                  is_top_level_path: true,
                )
              when "privacy"
                Page.new(
                  slug: slug,
                  body_html: html,
                  title: I18n.t("admin.pages_controller.privacy_policy"),
                  description: I18n.t("admin.pages_controller.a_page_that_describes_the"),
                  is_top_level_path: true,
                )
              when "terms"
                Page.new(
                  slug: slug,
                  body_html: html,
                  title: I18n.t("admin.pages_controller.terms_of_use"),
                  description: I18n.t("admin.pages_controller.a_page_that_describes_the2"),
                  is_top_level_path: true,
                )
              else
                Page.new
              end
    end
  end
end
