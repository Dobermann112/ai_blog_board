class Post < ApplicationRecord
  belongs_to :user

  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :favorites, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true, unless: :draft?
  validates :body, presence: true, unless: :draft?
  validate :title_or_body_present, if: :draft?

  scope :published, -> { where(draft: false) }
  scope :drafts, -> { where(draft: true) }

  private

  def title_or_body_present
    errors.add(:base, "タイトルまたは本文のいずれかを入力してください") if title.blank? && body.blank?
  end
end
