require "application_system_test_case"

class RecipesSystemTest < ApplicationSystemTestCase
  setup do
    @recipe = recipes(:one)
  end

  test "visiting the index" do
    visit recipes_url
    assert_selector "h1", text: "Recipes"
  end

  test "creating a recipe" do
    visit recipes_url
    click_on "New Recipe"

    fill_in "Title", with: "Chocolate Cake"
    fill_in "Description", with: "A delicious chocolate cake"
    fill_in "Instructions", with: "Mix ingredients and bake"
    fill_in "Servings", with: 8
    fill_in "Prep time", with: 15
    fill_in "Cook time", with: 30

    click_on "Create Recipe"

    assert_text "Recipe was successfully created"
    assert_text "Chocolate Cake"
  end

  test "creating a recipe with ingredients" do
    visit new_recipe_url

    fill_in "Title", with: "Pancakes"
    fill_in "Instructions", with: "Mix and cook on griddle"

    # Add first ingredient
    fill_in "Name", with: "Flour", match: :first
    fill_in "Quantity", with: "2", match: :first
    fill_in "Unit", with: "cups", match: :first

    click_on "Create Recipe"

    assert_text "Recipe was successfully created"
    assert_text "Pancakes"
  end

  test "creating a recipe with tags" do
    visit new_recipe_url

    fill_in "Title", with: "Salad"
    fill_in "Tag list", with: "healthy, vegetarian, quick"

    click_on "Create Recipe"

    assert_text "Recipe was successfully created"
    assert_text "Healthy"
    assert_text "Vegetarian"
  end

  test "showing a recipe" do
    visit recipe_url(@recipe)
    assert_selector "h1", text: @recipe.title
  end

  test "updating a recipe" do
    visit recipe_url(@recipe)
    click_on "Edit"

    fill_in "Title", with: "Updated Recipe Title"
    fill_in "Rating", with: 5

    click_on "Update Recipe"

    assert_text "Recipe was successfully updated"
    assert_text "Updated Recipe Title"
  end

  test "destroying a recipe" do
    visit recipe_url(@recipe)
    click_on "Edit"
    click_on "Delete", match: :first

    assert_text "Recipe was successfully deleted"
  end

  test "searching recipes" do
    Recipe.create!(title: "Chocolate Cake", description: "Delicious chocolate dessert")
    Recipe.create!(title: "Vanilla Ice Cream", description: "Creamy vanilla treat")

    visit recipes_url
    fill_in "Search", with: "chocolate"
    click_on "Search"

    assert_text "Chocolate Cake"
    refute_text "Vanilla Ice Cream"
  end

  test "filtering by tag" do
    tag = Tag.create!(name: "Dessert")
    @recipe.tags << tag

    visit recipes_url(tag: "Dessert")

    assert_text @recipe.title
  end

  test "navigating to scan page" do
    visit recipes_url
    click_on "Scan Recipe"

    assert_selector "h1", text: "Scan Recipe"
  end
end
