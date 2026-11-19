class NutritionCalculator
  # Basic nutrition database for common ingredients (per 100g)
  # Values are approximate averages from USDA data
  NUTRITION_DB = {
    # Common ingredients with nutrition per 100g
    "flour" => { calories: 364, carbohydrates: 76.3, cholesterol: 0, sodium: 2, fat: 1, protein: 10 },
    "sugar" => { calories: 387, carbohydrates: 100, cholesterol: 0, sodium: 1, fat: 0, protein: 0 },
    "butter" => { calories: 717, carbohydrates: 0.1, cholesterol: 215, sodium: 11, fat: 81, protein: 0.9 },
    "egg" => { calories: 143, carbohydrates: 0.7, cholesterol: 372, sodium: 142, fat: 9.5, protein: 12.6 },
    "egg white" => { calories: 52, carbohydrates: 0.2, cholesterol: 0, sodium: 166, fat: 0.2, protein: 10.9 },
    "egg yolk" => { calories: 322, carbohydrates: 3.6, cholesterol: 1085, sodium: 48, fat: 26.5, protein: 15.9 },
    "milk" => { calories: 42, carbohydrates: 4.8, cholesterol: 14, sodium: 44, fat: 1, protein: 3.4 },
    "cheese" => { calories: 402, carbohydrates: 1.3, cholesterol: 95, sodium: 621, fat: 33, protein: 25 },
    "cheddar cheese" => { calories: 403, carbohydrates: 1.3, cholesterol: 99, sodium: 621, fat: 33, protein: 25 },
    "mozzarella cheese" => { calories: 280, carbohydrates: 3.1, cholesterol: 79, sodium: 16, fat: 17, protein: 28 },
    "parmesan cheese" => { calories: 431, carbohydrates: 3.2, cholesterol: 68, sodium: 1529, fat: 29, protein: 38 },
    "chicken breast" => { calories: 165, carbohydrates: 0, cholesterol: 85, sodium: 74, fat: 3.6, protein: 31 },
    "chicken thigh" => { calories: 209, carbohydrates: 0, cholesterol: 109, sodium: 86, fat: 12, protein: 27 },
    "ground chicken" => { calories: 189, carbohydrates: 0, cholesterol: 109, sodium: 77, fat: 9.7, protein: 28 },
    "beef" => { calories: 250, carbohydrates: 0, cholesterol: 70, sodium: 60, fat: 15, protein: 26 },
    "ground beef" => { calories: 250, carbohydrates: 0, cholesterol: 70, sodium: 60, fat: 15, protein: 26 },
    "pork" => { calories: 242, carbohydrates: 0, cholesterol: 90, sodium: 62, fat: 14, protein: 27 },
    "bacon" => { calories: 541, carbohydrates: 1.4, cholesterol: 110, sodium: 1717, fat: 42, protein: 37 },
    "rice" => { calories: 130, carbohydrates: 28, cholesterol: 0, sodium: 1, fat: 0.3, protein: 2.7 },
    "brown rice" => { calories: 111, carbohydrates: 23, cholesterol: 0, sodium: 5, fat: 0.9, protein: 2.6 },
    "pasta" => { calories: 131, carbohydrates: 25, cholesterol: 0, sodium: 6, fat: 1.1, protein: 5 },
    "spaghetti" => { calories: 131, carbohydrates: 25, cholesterol: 0, sodium: 6, fat: 1.1, protein: 5 },
    "bread" => { calories: 265, carbohydrates: 49, cholesterol: 0, sodium: 492, fat: 3.2, protein: 9 },
    "whole wheat bread" => { calories: 247, carbohydrates: 41, cholesterol: 0, sodium: 490, fat: 3.4, protein: 13 },
    "olive oil" => { calories: 884, carbohydrates: 0, cholesterol: 0, sodium: 2, fat: 100, protein: 0 },
    "vegetable oil" => { calories: 884, carbohydrates: 0, cholesterol: 0, sodium: 0, fat: 100, protein: 0 },
    "canola oil" => { calories: 884, carbohydrates: 0, cholesterol: 0, sodium: 0, fat: 100, protein: 0 },
    "coconut oil" => { calories: 862, carbohydrates: 0, cholesterol: 0, sodium: 0, fat: 100, protein: 0 },
    "onion" => { calories: 40, carbohydrates: 9.3, cholesterol: 0, sodium: 4, fat: 0.1, protein: 1.1 },
    "garlic" => { calories: 149, carbohydrates: 33, cholesterol: 0, sodium: 17, fat: 0.5, protein: 6.4 },
    "tomato" => { calories: 18, carbohydrates: 3.9, cholesterol: 0, sodium: 5, fat: 0.2, protein: 0.9 },
    "carrot" => { calories: 41, carbohydrates: 9.6, cholesterol: 0, sodium: 69, fat: 0.2, protein: 0.9 },
    "potato" => { calories: 77, carbohydrates: 17, cholesterol: 0, sodium: 6, fat: 0.1, protein: 2 },
    "sweet potato" => { calories: 86, carbohydrates: 20, cholesterol: 0, sodium: 5, fat: 0.1, protein: 1.6 },
    "broccoli" => { calories: 34, carbohydrates: 7, cholesterol: 0, sodium: 33, fat: 0.4, protein: 2.8 },
    "spinach" => { calories: 23, carbohydrates: 3.6, cholesterol: 0, sodium: 79, fat: 0.4, protein: 2.9 },
    "kale" => { calories: 35, carbohydrates: 4.9, cholesterol: 0, sodium: 38, fat: 0.6, protein: 2.9 },
    "lettuce" => { calories: 15, carbohydrates: 2.9, cholesterol: 0, sodium: 28, fat: 0.2, protein: 1.4 },
    "bell pepper" => { calories: 31, carbohydrates: 6, cholesterol: 0, sodium: 4, fat: 0.3, protein: 1 },
    "cucumber" => { calories: 16, carbohydrates: 3.6, cholesterol: 0, sodium: 2, fat: 0.1, protein: 0.7 },
    "zucchini" => { calories: 17, carbohydrates: 3.1, cholesterol: 0, sodium: 8, fat: 0.3, protein: 1.2 },
    "squash" => { calories: 17, carbohydrates: 3.1, cholesterol: 0, sodium: 8, fat: 0.3, protein: 1.2 },
    "mushroom" => { calories: 22, carbohydrates: 3.3, cholesterol: 0, sodium: 5, fat: 0.3, protein: 3.1 },
    "salt" => { calories: 0, carbohydrates: 0, cholesterol: 0, sodium: 38758, fat: 0, protein: 0 },
    "pepper" => { calories: 255, carbohydrates: 64, cholesterol: 0, sodium: 20, fat: 3.3, protein: 10 },
    "black pepper" => { calories: 255, carbohydrates: 64, cholesterol: 0, sodium: 20, fat: 3.3, protein: 10 },
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
    "whole wheat flour" => { calories: 340, carbohydrates: 72, cholesterol: 0, sodium: 2, fat: 1, protein: 13 },
    "almond flour" => { calories: 571, carbohydrates: 19, cholesterol: 0, sodium: 7, fat: 49, protein: 21 },
    "coconut flour" => { calories: 332, carbohydrates: 60, cholesterol: 0, sodium: 77, fat: 13, protein: 20 },
    "cream" => { calories: 340, carbohydrates: 2.9, cholesterol: 137, sodium: 37, fat: 37, protein: 2.1 },
    "heavy cream" => { calories: 340, carbohydrates: 2.9, cholesterol: 137, sodium: 37, fat: 37, protein: 2.1 },
    "sour cream" => { calories: 181, carbohydrates: 4.3, cholesterol: 52, sodium: 49, fat: 18, protein: 2.4 },
    "yogurt" => { calories: 59, carbohydrates: 3.6, cholesterol: 5, sodium: 36, fat: 3.3, protein: 10 },
    "greek yogurt" => { calories: 59, carbohydrates: 3.6, cholesterol: 5, sodium: 36, fat: 3.3, protein: 10 },
    "mayonnaise" => { calories: 680, carbohydrates: 0.6, cholesterol: 85, sodium: 674, fat: 75, protein: 1 },
    "ketchup" => { calories: 101, carbohydrates: 28, cholesterol: 0, sodium: 907, fat: 0.1, protein: 1 },
    "mustard" => { calories: 66, carbohydrates: 4.9, cholesterol: 0, sodium: 1100, fat: 3.3, protein: 4 },
    "soy sauce" => { calories: 53, carbohydrates: 4.9, cholesterol: 0, sodium: 5550, fat: 0, protein: 10 },
    "hot sauce" => { calories: 29, carbohydrates: 0, cholesterol: 0, sodium: 1247, fat: 0.3, protein: 0 },
    "tuna" => { calories: 116, carbohydrates: 0, cholesterol: 42, sodium: 37, fat: 0.8, protein: 26 },
    "canned tuna" => { calories: 116, carbohydrates: 0, cholesterol: 42, sodium: 37, fat: 0.8, protein: 26 },
    "salmon" => { calories: 208, carbohydrates: 0, cholesterol: 63, sodium: 59, fat: 13, protein: 20 },
    "shrimp" => { calories: 99, carbohydrates: 0.2, cholesterol: 152, sodium: 111, fat: 0.3, protein: 24 },
    "beans" => { calories: 347, carbohydrates: 63, cholesterol: 0, sodium: 6, fat: 1.2, protein: 21 },
    "black beans" => { calories: 347, carbohydrates: 63, cholesterol: 0, sodium: 6, fat: 1.2, protein: 21 },
    "kidney beans" => { calories: 337, carbohydrates: 61, cholesterol: 0, sodium: 6, fat: 0.5, protein: 23 },
    "chickpeas" => { calories: 364, carbohydrates: 61, cholesterol: 0, sodium: 24, fat: 6, protein: 19 },
    "lentils" => { calories: 353, carbohydrates: 60, cholesterol: 0, sodium: 6, fat: 1.1, protein: 25 },
    "peanut butter" => { calories: 588, carbohydrates: 20, cholesterol: 0, sodium: 390, fat: 50, protein: 25 },
    "almond butter" => { calories: 614, carbohydrates: 19, cholesterol: 0, sodium: 7, fat: 55, protein: 21 },
    "walnuts" => { calories: 654, carbohydrates: 14, cholesterol: 0, sodium: 2, fat: 65, protein: 15 },
    "almonds" => { calories: 579, carbohydrates: 22, cholesterol: 0, sodium: 1, fat: 50, protein: 21 },
    "pecans" => { calories: 691, carbohydrates: 14, cholesterol: 0, sodium: 0, fat: 72, protein: 9 },
    "cashews" => { calories: 553, carbohydrates: 30, cholesterol: 0, sodium: 12, fat: 44, protein: 18 },
    "avocado" => { calories: 160, carbohydrates: 8.5, cholesterol: 0, sodium: 7, fat: 15, protein: 2 },
    "banana" => { calories: 89, carbohydrates: 23, cholesterol: 0, sodium: 1, fat: 0.3, protein: 1.1 },
    "apple" => { calories: 52, carbohydrates: 14, cholesterol: 0, sodium: 1, fat: 0.2, protein: 0.3 },
    "orange" => { calories: 47, carbohydrates: 12, cholesterol: 0, sodium: 0, fat: 0.1, protein: 0.9 },
    "lemon" => { calories: 29, carbohydrates: 9.3, cholesterol: 0, sodium: 2, fat: 0.3, protein: 1.1 },
    "lime" => { calories: 30, carbohydrates: 10.5, cholesterol: 0, sodium: 2, fat: 0.2, protein: 0.7 },
    "strawberries" => { calories: 32, carbohydrates: 7.7, cholesterol: 0, sodium: 1, fat: 0.3, protein: 0.7 },
    "blueberries" => { calories: 57, carbohydrates: 14, cholesterol: 0, sodium: 1, fat: 0.3, protein: 0.7 },
    "raspberries" => { calories: 52, carbohydrates: 12, cholesterol: 0, sodium: 1, fat: 0.7, protein: 1.2 },
    "cinnamon" => { calories: 247, carbohydrates: 81, cholesterol: 0, sodium: 10, fat: 1.2, protein: 4 },
    "cumin" => { calories: 375, carbohydrates: 44, cholesterol: 0, sodium: 168, fat: 22, protein: 18 },
    "paprika" => { calories: 282, carbohydrates: 34, cholesterol: 0, sodium: 236, fat: 15, protein: 14 },
    "oregano" => { calories: 265, carbohydrates: 69, cholesterol: 0, sodium: 25, fat: 4.3, protein: 9 },
    "basil" => { calories: 23, carbohydrates: 2.7, cholesterol: 0, sodium: 4, fat: 0.6, protein: 3.2 },
    "parsley" => { calories: 36, carbohydrates: 6.3, cholesterol: 0, sodium: 104, fat: 0.8, protein: 3 },
    "cilantro" => { calories: 23, carbohydrates: 3.7, cholesterol: 0, sodium: 46, fat: 0.5, protein: 2.1 },
    "thyme" => { calories: 101, carbohydrates: 24, cholesterol: 0, sodium: 9, fat: 1.7, protein: 6 },
    "rosemary" => { calories: 131, carbohydrates: 21, cholesterol: 0, sodium: 50, fat: 5.9, protein: 4.9 },
    "sage" => { calories: 315, carbohydrates: 61, cholesterol: 0, sodium: 11, fat: 13, protein: 10 },
    "turmeric" => { calories: 354, carbohydrates: 44, cholesterol: 0, sodium: 38, fat: 10, protein: 8 },
    "ginger" => { calories: 80, carbohydrates: 18, cholesterol: 0, sodium: 13, fat: 0.8, protein: 1.8 },
    "cayenne pepper" => { calories: 318, carbohydrates: 57, cholesterol: 0, sodium: 1950, fat: 17, protein: 12 },
    "maple syrup" => { calories: 260, carbohydrates: 67, cholesterol: 0, sodium: 12, fat: 0.1, protein: 0 },
    "agave nectar" => { calories: 310, carbohydrates: 76, cholesterol: 0, sodium: 0, fat: 0.5, protein: 0.1 },
    "cornstarch" => { calories: 381, carbohydrates: 91, cholesterol: 0, sodium: 1, fat: 0.1, protein: 0.3 },
    "gelatin" => { calories: 335, carbohydrates: 0, cholesterol: 0, sodium: 200, fat: 0, protein: 86 },
    "yeast" => { calories: 325, carbohydrates: 41, cholesterol: 0, sodium: 51, fat: 8, protein: 40 }
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
