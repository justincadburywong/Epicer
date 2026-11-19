class NutritionCalculator
  # Basic nutrition database for common ingredients (per 100g)
  # Values are approximate averages from USDA data
  NUTRITION_DB = {
    # Common ingredients with nutrition per 100g
    "flour" => { calories: 364, carbohydrates: 76.3, cholesterol: 0, sodium: 2, fat: 1, protein: 10 },
    "sugar" => { calories: 387, carbohydrates: 100, cholesterol: 0, sodium: 1, fat: 0, protein: 0 },
    "butter" => { calories: 717, carbohydrates: 0.1, cholesterol: 215, sodium: 11, fat: 81, protein: 0.9 },
    "egg" => { calories: 143, carbohydrates: 0.7, cholesterol: 372, sodium: 142, fat: 9.5, protein: 12.6 },
    "milk" => { calories: 42, carbohydrates: 4.8, cholesterol: 14, sodium: 44, fat: 1, protein: 3.4 },
    "cheese" => { calories: 402, carbohydrates: 1.3, cholesterol: 95, sodium: 621, fat: 33, protein: 25 },
    "chicken breast" => { calories: 165, carbohydrates: 0, cholesterol: 85, sodium: 74, fat: 3.6, protein: 31 },
    "beef" => { calories: 250, carbohydrates: 0, cholesterol: 70, sodium: 60, fat: 15, protein: 26 },
    "rice" => { calories: 130, carbohydrates: 28, cholesterol: 0, sodium: 1, fat: 0.3, protein: 2.7 },
    "pasta" => { calories: 131, carbohydrates: 25, cholesterol: 0, sodium: 6, fat: 1.1, protein: 5 },
    "bread" => { calories: 265, carbohydrates: 49, cholesterol: 0, sodium: 492, fat: 3.2, protein: 9 },
    "olive oil" => { calories: 884, carbohydrates: 0, cholesterol: 0, sodium: 2, fat: 100, protein: 0 },
    "vegetable oil" => { calories: 884, carbohydrates: 0, cholesterol: 0, sodium: 0, fat: 100, protein: 0 },
    "onion" => { calories: 40, carbohydrates: 9.3, cholesterol: 0, sodium: 4, fat: 0.1, protein: 1.1 },
    "garlic" => { calories: 149, carbohydrates: 33, cholesterol: 0, sodium: 17, fat: 0.5, protein: 6.4 },
    "tomato" => { calories: 18, carbohydrates: 3.9, cholesterol: 0, sodium: 5, fat: 0.2, protein: 0.9 },
    "carrot" => { calories: 41, carbohydrates: 9.6, cholesterol: 0, sodium: 69, fat: 0.2, protein: 0.9 },
    "potato" => { calories: 77, carbohydrates: 17, cholesterol: 0, sodium: 6, fat: 0.1, protein: 2 },
    "broccoli" => { calories: 34, carbohydrates: 7, cholesterol: 0, sodium: 33, fat: 0.4, protein: 2.8 },
    "spinach" => { calories: 23, carbohydrates: 3.6, cholesterol: 0, sodium: 79, fat: 0.4, protein: 2.9 },
    "salt" => { calories: 0, carbohydrates: 0, cholesterol: 0, sodium: 38758, fat: 0, protein: 0 },
    "pepper" => { calories: 255, carbohydrates: 64, cholesterol: 0, sodium: 20, fat: 3.3, protein: 10 },
    "vanilla extract" => { calories: 288, carbohydrates: 12.7, cholesterol: 0, sodium: 9, fat: 0.1, protein: 0.1 },
    "baking powder" => { calories: 97, carbohydrates: 21, cholesterol: 0, sodium: 4330, fat: 0, protein: 2.6 },
    "baking soda" => { calories: 0, carbohydrates: 0, cholesterol: 0, sodium: 27360, fat: 0, protein: 0 },
    "chocolate chips" => { calories: 479, carbohydrates: 67, cholesterol: 0, sodium: 24, fat: 24, protein: 6 },
    "oats" => { calories: 389, carbohydrates: 66, cholesterol: 0, sodium: 6, fat: 6.9, protein: 17 },
    "honey" => { calories: 304, carbohydrates: 82, cholesterol: 0, sodium: 4, fat: 0, protein: 0.3 },
    "brown sugar" => { calories: 380, carbohydrates: 98, cholesterol: 0, sodium: 29, fat: 0, protein: 0 },
    "corn flakes" => { calories: 383, carbohydrates: 84, cholesterol: 0, sodium: 657, fat: 0.4, protein: 7 },
    "dark brown sugar" => { calories: 380, carbohydrates: 98, cholesterol: 0, sodium: 29, fat: 0, protein: 0 },
    "semi sweet chocolate chips" => { calories: 479, carbohydrates: 67, cholesterol: 0, sodium: 24, fat: 24, protein: 6 },
    "all purpose flour" => { calories: 364, carbohydrates: 76, cholesterol: 0, sodium: 2, fat: 1, protein: 10 },
    "baking soda" => { calories: 0, carbohydrates: 0, cholesterol: 0, sodium: 27360, fat: 0, protein: 0 },
    "salt" => { calories: 0, carbohydrates: 0, cholesterol: 0, sodium: 38758, fat: 0, protein: 0 }
  }.freeze

  def initialize(recipe)
    @recipe = recipe
  end

  def calculate
    total_nutrition = {
      calories: 0,
      carbohydrates: 0,
      cholesterol: 0,
      sodium: 0,
      fat: 0,
      protein: 0
    }

    @recipe.ingredients.each do |ingredient|
      ingredient_nutrition = lookup_nutrition(ingredient)
      if ingredient_nutrition
        # Scale by quantity (assuming quantity is in grams or similar unit)
        # This is a simplified calculation - in reality, we'd need to convert units
        scale_factor = ingredient.quantity || 1
        total_nutrition[:calories] += ingredient_nutrition[:calories] * scale_factor / 100
        total_nutrition[:carbohydrates] += ingredient_nutrition[:carbohydrates] * scale_factor / 100
        total_nutrition[:cholesterol] += ingredient_nutrition[:cholesterol] * scale_factor / 100
        total_nutrition[:sodium] += ingredient_nutrition[:sodium] * scale_factor / 100
        total_nutrition[:fat] += ingredient_nutrition[:fat] * scale_factor / 100
        total_nutrition[:protein] += ingredient_nutrition[:protein] * scale_factor / 100
      end
    end

    # Calculate per serving
    servings = @recipe.servings || 1
    {
      calories: (total_nutrition[:calories] / servings).round(1),
      carbohydrates: (total_nutrition[:carbohydrates] / servings).round(1),
      cholesterol: (total_nutrition[:cholesterol] / servings).round(1),
      sodium: (total_nutrition[:sodium] / servings).round(1),
      fat: (total_nutrition[:fat] / servings).round(1),
      protein: (total_nutrition[:protein] / servings).round(1)
    }
  end

  private

  def lookup_nutrition(ingredient)
    # Try to find a match in our nutrition database
    ingredient_name = ingredient.name.downcase
    NUTRITION_DB.each do |key, value|
      if ingredient_name.include?(key) || key.include?(ingredient_name)
        return value
      end
    end
    nil
  end
end
