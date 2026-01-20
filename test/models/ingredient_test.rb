require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  setup do
    @recipe = Recipe.create!(title: "Test Recipe", servings: 4)
  end

  test "requires a name" do
    ingredient = Ingredient.new(recipe: @recipe, name: nil)
    assert_not ingredient.valid?
  end

  test "scaled_quantity doubles for double servings" do
    ingredient = @recipe.ingredients.create!(name: "flour", quantity: 2, unit: "cups")
    assert_equal 4.0, ingredient.scaled_quantity(8)
  end

  test "scaled_quantity halves for half servings" do
    ingredient = @recipe.ingredients.create!(name: "sugar", quantity: 1, unit: "cup")
    assert_equal 0.5, ingredient.scaled_quantity(2)
  end

  test "scaled_quantity returns original when recipe has no servings" do
    recipe_no_servings = Recipe.create!(title: "No Servings", servings: nil)
    ingredient = recipe_no_servings.ingredients.create!(name: "salt", quantity: 1, unit: "tsp")
    assert_equal 1, ingredient.scaled_quantity(8)
  end

  test "display_quantity formats whole numbers without decimals" do
    ingredient = @recipe.ingredients.create!(name: "eggs", quantity: 3, unit: nil)
    assert_equal "3", ingredient.display_quantity
  end

  test "display_quantity shows decimals when needed" do
    ingredient = @recipe.ingredients.create!(name: "butter", quantity: 1.5, unit: "cups")
    assert_equal "1.5", ingredient.display_quantity
  end
end
