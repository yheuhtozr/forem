class PollSkip < ApplicationRecord
  belongs_to :poll
  belongs_to :user

  validate :one_vote_per_poll_per_user

  private

  def one_vote_per_poll_per_user
    return false unless poll
    return false unless poll.vote_previously_recorded_for?(user_id: user_id)

    errors.add(:base, I18n.t("models.poll_skip.cannot_vote_more_than_once"))
  end
end
