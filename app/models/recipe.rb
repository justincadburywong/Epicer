class Recipe < ApplicationRecord

  belongs_to :user

  validates :name, :descrition, :category, :ingredient1, :instruction1, presence: true, length: { minimum: 3 }
  validates :quantity1, presence: true

end
