class TagAdjustment < ApplicationRecord
  validates :user_id, presence: true
  validates :article_id, presence: true
  validates :tag_id, presence: true
  validates :tag_name, presence: true,
                       uniqueness: { scope: :article_id, message: I18n.t("models.tag_adjustment.unique") }
  validates :reason_for_adjustment, presence: true
  validates :adjustment_type, inclusion: { in: %w[removal addition] }, presence: true
  validates :status, inclusion: { in: %w[committed pending committed_and_resolvable resolved] }, presence: true
  has_many :notifications, as: :notifiable, inverse_of: :notifiable, dependent: :delete_all
  validate :user_permissions
  validate :article_tag_list

  belongs_to :user
  belongs_to :tag
  belongs_to :article

  private

  def user_permissions
    errors.add(:user_id, I18n.t("models.tag_adjustment.does_not_have_privilege_to")) unless has_privilege_to_adjust?
  end

  def has_privilege_to_adjust?
    return false unless user

    user.has_role?(:tag_moderator, tag) ||
      user.has_role?(:admin) ||
      user.has_role?(:super_admin)
  end

  def article_tag_list
    if adjustment_type == "removal" && article.tag_list.none? do |tag|
         tag.casecmp(tag_name).zero?
       end
      errors.add(:tag_id,
                 I18n.t("models.tag_adjustment.selected_for_removal_is_no"))
    end
    return unless adjustment_type == "addition" && article.tag_list.count > 3

    errors.add(:base, I18n.t("models.tag_adjustment.4_tags_max_per_article"))
  end
end
