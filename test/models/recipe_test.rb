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

  test "search finds recipes by title" do
    Recipe.create!(title: "Chocolate Cake")
    Recipe.create!(title: "Vanilla Ice Cream")
    
    results = Recipe.search("chocolate")
    assert_equal 1, results.count
    assert_equal "Chocolate Cake", results.first.title
  end

  test "search returns all when query is blank" do
    Recipe.create!(title: "Recipe 1")
    Recipe.create!(title: "Recipe 2")
    
    assert_equal 2, Recipe.search("").count
    assert_equal 2, Recipe.search(nil).count
  end

  test "total_time sums prep and cook time" do
    recipe = Recipe.new(prep_time: 15, cook_time: 30)
    assert_equal 45, recipe.total_time
  end

  test "total_time handles nil values" do
    recipe = Recipe.new(prep_time: nil, cook_time: 20)
    assert_equal 20, recipe.total_time
  end
end
