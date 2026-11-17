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
      if match = fraction_str.match(/(\d+)\/(\d+)/)
        match[1].to_f / match[2].to_f + whole_number
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

      # Convert decimal part to fraction by finding nearest common fraction
      fraction_part = nearest_fraction(decimal_part)

      if fraction_part && decimal_part > 0.0625  # Only show fraction if significant
        "#{whole_part} #{fraction_part}"
      else
        whole_part.to_s
      end
    else
      # For quantities < 1, find nearest common fraction
      fraction_str = nearest_fraction(qty)
      if fraction_str && qty > 0.0625
        fraction_str
      elsif qty <= 1.0625
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

  def nearest_fraction(decimal)
    return nil if decimal.nil? || decimal <= 0

    # Common fractions with their decimal values
    fractions = {
      "1/8" => 0.125,
      "1/6" => 0.1667,
      "1/4" => 0.25,
      "1/3" => 0.3333,
      "3/8" => 0.375,
      "1/2" => 0.5,
      "5/8" => 0.625,
      "2/3" => 0.6667,
      "3/4" => 0.75,
      "5/6" => 0.8333,
      "7/8" => 0.875
    }

    # Find the fraction with the smallest distance to the decimal
    closest = fractions.min_by { |_, value| (decimal - value).abs }

    closest&.first
  end
end
