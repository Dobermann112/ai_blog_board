class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :followed_id, uniqueness: { scope: :follower_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    return if follower_id.blank? || followed_id.blank?

    errors.add(:base, "自分自身をフォローすることはできません") if follower_id == followed_id
  end
end
