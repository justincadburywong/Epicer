class Recipe < ApplicationRecord

  belongs_to :user

  validates :name, presence: true, length: { maximum:32 }, allow_nil: false
  validates :description, :category, :ingredient1, :quantity1, :instruction1, presence: true, allow_nil: false
  validates :description, :instruction1, length: { minimum: 3, maximum: 256 }
end
