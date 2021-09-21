module Admin
  class BadgeAchievementsController < Admin::ApplicationController
    layout "admin"

    def index
      @q = BadgeAchievement
        .includes(:badge)
        .includes(:user)
        .order(created_at: :desc)
        .ransack(params[:q])
      @badge_achievements = @q.result.page(params[:page] || 1).per(15)
    end

    def destroy
      @badge_achievement = BadgeAchievement.find(params[:id])

      if @badge_achievement.destroy
        flash[:success] = I18n.t("admin.badge_achievements_controller.badge_achievement_has_been")
      else
        render json: { error: "Something went wrong." }, status: :unprocessable_entity
      end
    end

    def award
      @all_badges = Badge.all.select(:title, :slug)
    end

    def award_badges
      if permitted_params[:badge].blank?
        raise ArgumentError,
              I18n.t("admin.badge_achievements_controller.please_choose_a_badge_to_a")
      end

      usernames = permitted_params[:usernames].downcase.split(/\s*,\s*/)
      message = permitted_params[:message_markdown].presence || I18n.t("admin.badge_achievements_controller.congrats")
      BadgeAchievements::BadgeAwardWorker.perform_async(usernames, permitted_params[:badge], message)

      flash[:success] = I18n.t("admin.badge_achievements_controller.badges_are_being_rewarded")
      redirect_to admin_badge_achievements_path
    rescue ArgumentError => e
      flash[:danger] = e.message
      redirect_to admin_badge_achievements_path
    end

    private

    def permitted_params
      params.permit(:usernames, :badge, :message_markdown)
    end
  end
end
