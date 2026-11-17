require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  setup do
    @recipe = Recipe.create!(title: "Test Recipe", servings: 4)
  end

  test "requires a name" do
    ingredient = Ingredient.new(recipe: @recipe, name: nil)
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:name], "can't be blank"
  end

  test "validates quantity is greater than 0" do
    ingredient = Ingredient.new(recipe: @recipe, name: "Flour", quantity: 0)
    assert_not ingredient.valid?

    ingredient.quantity = 2
    assert ingredient.valid?
  end

  test "allows nil quantity" do
    ingredient = Ingredient.new(recipe: @recipe, name: "Salt", quantity: nil)
    assert ingredient.valid?
  end

  test "allows negative quantity for edge cases" do
    ingredient = Ingredient.new(recipe: @recipe, name: "Flour", quantity: -1)
    assert_not ingredient.valid?
  end

  test "belongs to recipe" do
    ingredient = @recipe.ingredients.create!(name: "Flour")
    assert_equal @recipe, ingredient.recipe
  end

  test "scaled_quantity doubles for double servings" do
    ingredient = @recipe.ingredients.create!(name: "flour", quantity: 2, unit: "cups")
    assert_equal 4.0, ingredient.scaled_quantity(8)
  end

  test "scaled_quantity halves for half servings" do
    ingredient = @recipe.ingredients.create!(name: "sugar", quantity: 1, unit: "cup")
    assert_equal 0.5, ingredient.scaled_quantity(2)
  end

  test "scaled_quantity triples for triple servings" do
    ingredient = @recipe.ingredients.create!(name: "butter", quantity: 1, unit: "cup")
    assert_equal 3.0, ingredient.scaled_quantity(12)
  end

  test "scaled_quantity returns original when recipe has no servings" do
    recipe_no_servings = Recipe.create!(title: "No Servings", servings: nil)
    ingredient = recipe_no_servings.ingredients.create!(name: "salt", quantity: 1, unit: "tsp")
    assert_equal 1, ingredient.scaled_quantity(8)
  end

  test "scaled_quantity returns original when ingredient has no quantity" do
    ingredient = @recipe.ingredients.create!(name: "pinch of salt", quantity: nil, unit: nil)
    assert_nil ingredient.scaled_quantity(8)
  end

  test "display_quantity formats whole numbers without decimals" do
    ingredient = @recipe.ingredients.create!(name: "eggs", quantity: 3, unit: nil)
    assert_equal "3", ingredient.display_quantity
  end

  test "display_quantity shows decimals when needed" do
    ingredient = @recipe.ingredients.create!(name: "butter", quantity: 1.5, unit: "cups")
    assert_equal "1 1/2", ingredient.display_quantity
  end

  test "display_quantity shows fractions for common values" do
    ingredient = @recipe.ingredients.create!(name: "flour", quantity: 0.5, unit: "cups")
    assert_equal "1/2", ingredient.display_quantity
  end

  test "display_quantity handles mixed numbers" do
    ingredient = @recipe.ingredients.create!(name: "flour", quantity: 1.5, unit: "cups")
    assert_equal "1 1/2", ingredient.display_quantity
  end

  test "display_quantity with scaling" do
    ingredient = @recipe.ingredients.create!(name: "flour", quantity: 1, unit: "cups")
    assert_equal "2", ingredient.display_quantity(8)
  end

  test "display_quantity returns empty string when quantity is nil" do
    ingredient = @recipe.ingredients.create!(name: "salt", quantity: nil, unit: "pinch")
    assert_equal "", ingredient.display_quantity
  end

  test "parse_quantity handles whole numbers" do
    assert_equal 2.0, Ingredient.parse_quantity("2")
  end

  test "parse_quantity handles decimals" do
    assert_equal 2.5, Ingredient.parse_quantity("2.5")
  end

  test "parse_quantity handles simple fractions" do
    assert_equal 0.5, Ingredient.parse_quantity("1/2")
    assert_equal 0.75, Ingredient.parse_quantity("3/4")
  end

  test "parse_quantity handles mixed numbers" do
    assert_equal 1.5, Ingredient.parse_quantity("1 1/2")
    assert_equal 2.25, Ingredient.parse_quantity("2 1/4")
  end

  test "parse_quantity handles nil" do
    assert_nil Ingredient.parse_quantity(nil)
  end

  test "parse_quantity handles empty string" do
    assert_nil Ingredient.parse_quantity("")
  end

  test "position orders ingredients in recipe" do
    @recipe.ingredients.create!(name: "Sugar", position: 2)
    @recipe.ingredients.create!(name: "Flour", position: 1)
    @recipe.ingredients.create!(name: "Eggs", position: 3)

    assert_equal "Flour", @recipe.ingredients.first.name
    assert_equal "Eggs", @recipe.ingredients.last.name
  end
end
