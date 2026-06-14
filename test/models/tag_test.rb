require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "requires a name" do
    tag = Tag.new(name: nil)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "normalizes name before save" do
    tag = Tag.create!(name: "  chocolate  ")
    assert_equal "Chocolate", tag.name
  end

  test "name is case-insensitive unique" do
    Tag.create!(name: "Dessert")
    tag2 = Tag.new(name: "dessert")
    assert_not tag2.valid?
    assert_includes tag2.errors[:name], "has already been taken"
  end

  test "popular scope orders by recipe count" do
    tag1 = Tag.create!(name: "Popular")
    tag2 = Tag.create!(name: "Unpopular")
    tag3 = Tag.create!(name: "Medium")

    recipe1 = Recipe.create!(title: "Recipe 1")
    recipe2 = Recipe.create!(title: "Recipe 2")
    recipe3 = Recipe.create!(title: "Recipe 3")

    recipe1.tags << tag1
    recipe2.tags << tag1
    recipe3.tags << tag1
    recipe1.tags << tag3

    popular_tags = Tag.popular
    assert_equal tag1.id, popular_tags.first.id
  end

  test "has many recipes through recipe_tags" do
    tag = Tag.create!(name: "Dessert")
    recipe1 = Recipe.create!(title: "Cake")
    recipe2 = Recipe.create!(title: "Pie")

    tag.recipes << [recipe1, recipe2]

    assert_equal 2, tag.recipes.count
    assert_includes tag.recipes, recipe1
    assert_includes tag.recipes, recipe2
  end

  test "dependent destroy removes recipe_tags" do
    tag = Tag.create!(name: "Dessert")
    recipe = Recipe.create!(title: "Cake")
    recipe.tags << tag

    assert_difference "RecipeTag.count", -1 do
      tag.destroy
    end
  end
end
