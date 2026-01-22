class Recipe < ApplicationRecord
  has_many :ingredients, -> { order(:position) }, dependent: :destroy
  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  has_many_attached :images
  has_many_attached :documents
  extend FriendlyId
  friendly_id :title, use: :slugged

  accepts_nested_attributes_for :ingredients, allow_destroy: true, reject_if: :all_blank

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).reject(&:blank?).uniq.map do |name|
      Tag.find_or_create_by!(name: name.strip.downcase.titleize)
    end
  end

  validates :title, presence: true
  validates :servings, numericality: { greater_than: 0 }, allow_nil: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :prep_time, :cook_time, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :search, ->(query) {
    return all if query.blank?
    
    where(
      "title ILIKE :q OR description ILIKE :q OR instructions ILIKE :q OR notes ILIKE :q",
      q: "%#{sanitize_sql_like(query)}%"
    )
  }

  def total_time
    (prep_time || 0) + (cook_time || 0)
  end
end
