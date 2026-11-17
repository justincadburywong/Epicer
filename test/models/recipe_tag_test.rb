require "test_helper"

class RecipeTagTest < ActiveSupport::TestCase
  setup do
    @recipe = Recipe.create!(title: "Test Recipe")
    @tag = Tag.create!(name: "Dessert")
  end

  test "requires recipe" do
    recipe_tag = RecipeTag.new(tag: @tag)
    assert_not recipe_tag.valid?
  end

  test "requires tag" do
    recipe_tag = RecipeTag.new(recipe: @recipe)
    assert_not recipe_tag.valid?
  end

  test "prevents duplicate recipe-tag associations" do
    RecipeTag.create!(recipe: @recipe, tag: @tag)
    duplicate = RecipeTag.new(recipe: @recipe, tag: @tag)
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:recipe_id], "has already been taken"
  end

  test "allows same tag for different recipes" do
    recipe2 = Recipe.create!(title: "Another Recipe")
    
    RecipeTag.create!(recipe: @recipe, tag: @tag)
    recipe_tag2 = RecipeTag.new(recipe: recipe2, tag: @tag)
    
    assert recipe_tag2.valid?
  end

  test "allows same recipe with different tags" do
    tag2 = Tag.create!(name: "Sweet")
    
    RecipeTag.create!(recipe: @recipe, tag: @tag)
    recipe_tag2 = RecipeTag.new(recipe: @recipe, tag: tag2)
    
    assert recipe_tag2.valid?
  end
end
