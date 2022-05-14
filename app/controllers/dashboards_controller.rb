# @note The actions of this class are overloaded with three concerns:
#
#       - the current user
#       - a given user
#       - a given organization
#
#       The implementation details are such that things silently "fallback" to the current user's
#       information.  This fallback happens when we have quasi-policy checks say the current user
#       can't access the given user or given organization.
#
#       [@jeremyf] I'm including these notes for future refactors, as I've spent time trying to
#       improve legibility of the code but there are logical assumptions that require revisiting
#       (hence https://github.com/forem/forem/issues/16931).
class DashboardsController < ApplicationController
  before_action :set_no_cache_header
  before_action :authenticate_user!

  LIMIT_PER_PAGE_DEFAULT = 80
  LIMIT_PER_PAGE_MAX = 1000
  def show
    fetch_and_authorize_user
    target = @user
    # NOTE: This is a subtle policy check happening here that we are not encapsulating
    not_authorized if params[:org_id] && !(@user.org_admin?(params[:org_id]) || @user.any_admin?)

    @organizations = @user.admin_organizations

    # NOTE: This logic is a super set of the above not_authorized check
    if params[:which] == "organization" && params[:org_id] && (@user.org_admin?(params[:org_id]) || @user.any_admin?)
      target = @organizations.find_by(id: params[:org_id])
      @organization = target
      @articles = target.articles
    else
      # This redirect assumes that the dashboards#show action renders article specific information.
      # When a user doesn't have articles nor can they create them, we want to send them somewhere
      # else.
      redirect_to dashboard_following_tags_path unless policy(Article).has_existing_articles_or_can_create_new_ones?

      # if the target is a user, we need to eager load the organization
      @articles = target.articles.includes(:organization)
    end

    @reactions_count = @articles.sum(&:public_reactions_count)
    @page_views_count = @articles.sum(&:page_views_count)

    @articles = @articles.includes(:collection).sorting(params[:sort]).decorate
    @articles = Kaminari.paginate_array(@articles).page(params[:page]).per(50)
    @collections_count = target.collections.non_empty.count
  end

  def following_tags
    fetch_and_authorize_user
    @followed_tags = follows_for(user: @user, type: "ActsAsTaggableOn::Tag", order_by: :points)
    @collections_count = collections_count(@user)
  end

  def following_users
    fetch_and_authorize_user
    @follows = follows_for(user: @user, type: "User")
    @collections_count = collections_count(@user)
  end

  def following_organizations
    fetch_and_authorize_user
    @followed_organizations = follows_for(user: @user, type: "Organization")
    @collections_count = collections_count(@user)
  end

  def following_podcasts
    fetch_and_authorize_user
    @followed_podcasts = follows_for(user: @user, type: "Podcast")
    @collections_count = collections_count(@user)
  end

  def followers
    fetch_and_authorize_user
    @follows = Follow.followable_user(@user.id)
      .includes(:follower).order(created_at: :desc).limit(follows_limit)
    @collections_count = collections_count(@user)
  end

  def analytics
    @user_or_org = if params[:org_id]
                     Organization.find(params[:org_id])
                   else
                     current_user
                   end
    authorize(@user_or_org, :analytics?)
    @organizations = current_user.member_organizations
  end

  def subscriptions
    fetch_and_authorize_user
    set_source
    authorize @source
    @subscriptions = @source.user_subscriptions
      .includes(:subscriber).order(created_at: :desc).page(params[:page]).per(100)
  end

  private

  def follows_for(user:, type:, order_by: :created_at)
    user.follows_by_type(type).order(order_by => :desc).includes(:followable).limit(follows_limit)
  end

  def set_source
    source_type = UserSubscription::ALLOWED_TYPES.detect { |allowed_type| allowed_type == params[:source_type] }

    not_found unless source_type

    source = source_type.constantize.find_by(id: params[:source_id])
    @source = source || not_found
  end

  def fetch_and_authorize_user
    @user = if params[:username] && current_user.any_admin?
              User.find_by(username: params[:username])
            else
              current_user
            end
    # NOTE: later we expect @user so the `||` is a bit misleading.
    authorize (@user || User), :dashboard_show?
  end

  def follows_limit(default: LIMIT_PER_PAGE_DEFAULT, max: LIMIT_PER_PAGE_MAX)
    return default unless params.key?(:per_page)

    per_page = params[:per_page].to_i
    return max if per_page > max

    per_page
  end

  def collections_count(user)
    user.collections.non_empty.count
  end
end
