class Tag < ApplicationRecord
  has_many :recipe_tags, dependent: :destroy
  has_many :recipes, through: :recipe_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :normalize_name

  scope :popular, -> { joins(:recipe_tags).group(:id).order("COUNT(recipe_tags.id) DESC") }

  private

  def normalize_name
    self.name = name.strip.downcase.titleize
  end
end
