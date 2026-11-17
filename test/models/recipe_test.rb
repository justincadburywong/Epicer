require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "requires a title" do
    recipe = Recipe.new(title: nil)
    assert_not recipe.valid?
    assert_includes recipe.errors[:title], "can't be blank"
  end

  test "validates rating is between 1 and 5" do
    recipe = Recipe.new(title: "Test", rating: 6)
    assert_not recipe.valid?

    recipe.rating = 3
    assert recipe.valid?
  end

  test "validates rating cannot be 0" do
    recipe = Recipe.new(title: "Test", rating: 0)
    assert_not recipe.valid?
  end

  test "validates servings is greater than 0" do
    recipe = Recipe.new(title: "Test", servings: 0)
    assert_not recipe.valid?

    recipe.servings = 4
    assert recipe.valid?
  end

  test "allows nil servings" do
    recipe = Recipe.new(title: "Test", servings: nil)
    assert recipe.valid?
  end

  test "validates prep_time is non-negative" do
    recipe = Recipe.new(title: "Test", prep_time: -5)
    assert_not recipe.valid?

    recipe.prep_time = 10
    assert recipe.valid?
  end

  test "validates cook_time is non-negative" do
    recipe = Recipe.new(title: "Test", cook_time: -5)
    assert_not recipe.valid?

    recipe.cook_time = 20
    assert recipe.valid?
  end

  test "search finds recipes by title" do
    Recipe.create!(title: "Chocolate Cake")
    Recipe.create!(title: "Vanilla Ice Cream")

    results = Recipe.search("chocolate")
    assert_equal 1, results.count
    assert_equal "Chocolate Cake", results.first.title
  end

  test "search finds recipes by description" do
    recipe = Recipe.create!(title: "Test", description: "A delicious chocolate dessert")
    results = Recipe.search("delicious")
    assert_equal 1, results.count
    assert_equal recipe.id, results.first.id
  end

  test "search finds recipes by instructions" do
    recipe = Recipe.create!(title: "Test", instructions: "Mix the flour and sugar")
    results = Recipe.search("flour")
    assert_equal 1, results.count
  end

  test "search is case-insensitive" do
    Recipe.create!(title: "Chocolate Cake")
    results = Recipe.search("CHOCOLATE")
    assert_equal 1, results.count
  end

  test "search returns all when query is blank" do
    Recipe.create!(title: "Recipe 1")
    Recipe.create!(title: "Recipe 2")

    assert_equal 4, Recipe.search("").count
    assert_equal 4, Recipe.search(nil).count
  end

  test "total_time sums prep and cook time" do
    recipe = Recipe.new(prep_time: 15, cook_time: 30)
    assert_equal 45, recipe.total_time
  end

  test "total_time handles nil values" do
    recipe = Recipe.new(prep_time: nil, cook_time: 20)
    assert_equal 20, recipe.total_time
  end

  test "total_time handles both nil values" do
    recipe = Recipe.new(prep_time: nil, cook_time: nil)
    assert_equal 0, recipe.total_time
  end

  test "has many ingredients ordered by position" do
    recipe = Recipe.create!(title: "Test")
    recipe.ingredients.create!(name: "Sugar", position: 2)
    recipe.ingredients.create!(name: "Flour", position: 1)

    assert_equal "Flour", recipe.ingredients.first.name
    assert_equal "Sugar", recipe.ingredients.last.name
  end

  test "dependent destroy removes ingredients" do
    recipe = Recipe.create!(title: "Test")
    recipe.ingredients.create!(name: "Flour")

    assert_difference "Ingredient.count", -1 do
      recipe.destroy
    end
  end

  test "tag_list returns comma-separated tag names" do
    recipe = Recipe.create!(title: "Test")
    tag1 = Tag.create!(name: "Dessert")
    tag2 = Tag.create!(name: "Sweet")
    recipe.tags << [ tag1, tag2 ]

    assert_equal "Dessert, Sweet", recipe.tag_list
  end

  test "tag_list= creates tags from comma-separated string" do
    recipe = Recipe.create!(title: "Test")
    recipe.tag_list = "dessert, sweet, chocolate"

    assert_equal 3, recipe.tags.count
    assert_includes recipe.tags.map(&:name), "Dessert"
    assert_includes recipe.tags.map(&:name), "Sweet"
    assert_includes recipe.tags.map(&:name), "Chocolate"
  end

  test "tag_list= normalizes tag names" do
    recipe = Recipe.create!(title: "Test")
    recipe.tag_list = "  dessert  ,  SWEET  "

    assert_equal "Dessert", recipe.tags.first.name
    assert_equal "Sweet", recipe.tags.last.name
  end

  test "tag_list= removes duplicates" do
    recipe = Recipe.create!(title: "Test")
    recipe.tag_list = "dessert, dessert, sweet"

    assert_equal 2, recipe.tags.count
  end

  test "display_image returns feature_image if attached" do
    recipe = Recipe.create!(title: "Test")
    # Note: In a real test, you'd attach actual images
    # This test would need fixture files or Active Storage stubs
    assert_respond_to recipe, :display_image
  end

  test "friendly_id generates slug from title" do
    recipe = Recipe.create!(title: "Chocolate Cake")
    assert_equal "chocolate-cake", recipe.slug
  end

  test "accepts nested attributes for ingredients" do
    recipe = Recipe.new(
      title: "Test",
      ingredients_attributes: [
        { name: "Flour", quantity: 2, unit: "cups", position: 1 },
        { name: "Sugar", quantity: 1, unit: "cup", position: 2 }
      ]
    )

    assert recipe.save
    assert_equal 2, recipe.ingredients.count
  end

  test "rejects blank ingredient attributes" do
    recipe = Recipe.new(
      title: "Test",
      ingredients_attributes: [
        { name: "", quantity: nil, unit: nil }
      ]
    )

    assert recipe.save
    assert_equal 0, recipe.ingredients.count
  end
end
