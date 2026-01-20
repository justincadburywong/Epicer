class Recipe < ApplicationRecord
  has_many :ingredients, -> { order(:position) }, dependent: :destroy
  has_many_attached :images
  has_many_attached :documents

  accepts_nested_attributes_for :ingredients, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :servings, numericality: { greater_than: 0 }, allow_nil: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :prep_time, :cook_time, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def total_time
    (prep_time || 0) + (cook_time || 0)
  end
end
