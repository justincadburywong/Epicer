class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true

  # Parse quantity string to handle fractions, decimals, and whole numbers
  def self.parse_quantity(quantity_str)
    return nil if quantity_str.blank?
    
    # Handle fractions like "1 1/2", "3/4", "2 1/3"
    if quantity_str.match?(/\d+\s*\d+\/\d+|\d+\/\d+/)
      parts = quantity_str.split
      whole_number = 0
      
      # Extract whole number part
      if parts.length > 1
        whole_part = parts[0].match(/\d+/)
        whole_number = whole_part ? whole_part[0].to_f : 0
      end
      
      # Extract fraction part
      fraction_str = parts.last
      if fraction_str.match?(/(\d+)\/(\d+)/)
        numerator = $1.to_f
        denominator = $2.to_f
        whole_number + (numerator / denominator)
      else
        whole_number
      end
    else
      # Handle decimals and whole numbers
      quantity_str.to_f
    end
  end

  def scaled_quantity(new_servings)
    return quantity unless quantity && recipe.servings&.positive?
    (quantity * new_servings.to_f / recipe.servings).round(2)
  end

  def display_quantity(new_servings = nil)
    qty = new_servings ? scaled_quantity(new_servings) : quantity
    return "" unless qty
    
    # Handle mixed numbers (whole + fraction) for quantities > 1
    if qty >= 1
      whole_part = qty.floor
      decimal_part = qty - whole_part
      
      # Convert decimal part to fraction if it's close to common fractions
      fraction_part = if decimal_part < 0.125
        "1/8"
      elsif decimal_part < 0.1875
        "1/6"
      elsif decimal_part < 0.25
        "1/4"
      elsif decimal_part < 0.3125
        "1/3"
      elsif decimal_part < 0.375
        "3/8"
      elsif decimal_part < 0.4375
        "3/7"
      elsif decimal_part < 0.5
        "3/8"
      elsif decimal_part < 0.5625
        "1/2"
      elsif decimal_part < 0.625
        "5/8"
      elsif decimal_part < 0.6875
        "2/3"
      elsif decimal_part < 0.75
        "3/4"
      elsif decimal_part < 0.8125
        "5/6"
      elsif decimal_part < 0.875
        "7/8"
      elsif decimal_part < 0.9375
        "15/16"
      elsif decimal_part < 1.0625
        nil  # Whole number, no fraction needed
      else
        nil  # Use decimal for uncommon fractions
      end
      
      if fraction_part && decimal_part > 0.0625  # Only show fraction if significant
        "#{whole_part} #{fraction_part}"
      else
        whole_part.to_s
      end
    else
      # For quantities < 1, use existing fraction logic
      if qty < 0.125
        "1/8"
      elsif qty < 0.1875
        "1/6"
      elsif qty < 0.25
        "1/4"
      elsif qty < 0.3125
        "1/3"
      elsif qty < 0.375
        "3/8"
      elsif qty < 0.4375
        "3/7"
      elsif qty < 0.5
        "3/8"
      elsif qty < 0.5625
        "1/2"
      elsif qty < 0.625
        "5/8"
      elsif qty < 0.6875
        "2/3"
      elsif qty < 0.75
        "3/4"
      elsif qty < 0.8125
        "5/6"
      elsif qty < 0.875
        "7/8"
      elsif qty < 0.9375
        "15/16"
      elsif qty < 1.0625
        "1"
      else
        # For uncommon fractions, show decimal
        rounded = qty.round(2)
        if rounded == rounded.to_i
          rounded.to_i.to_s
        else
          rounded.to_s
        end
      end
    end
  end
end
