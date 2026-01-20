class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true

  def scaled_quantity(new_servings)
    return quantity unless quantity && recipe.servings&.positive?
    (quantity * new_servings.to_f / recipe.servings).round(2)
  end

  def display_quantity(new_servings = nil)
    qty = new_servings ? scaled_quantity(new_servings) : quantity
    return "" unless qty
    qty == qty.to_i ? qty.to_i.to_s : qty.to_s
  end
end
