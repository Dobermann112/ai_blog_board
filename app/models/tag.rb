class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :visible_to, ->(user) { user ? where(user_id: [ nil, user.id ]) : where(user_id: nil) }
end
