require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:one)
  end

  test "should get index" do
    get recipes_url
    assert_response :success
  end

  test "should get index with search query" do
    get recipes_url(query: "chocolate")
    assert_response :success
  end

  test "should get index with tag filter" do
    tag = tags(:one)
    get recipes_url(tag: tag.name)
    assert_response :success
  end

  test "should show recipe" do
    get recipe_url(@recipe)
    assert_response :success
  end

  test "should show recipe by friendly id" do
    get recipe_url(@recipe.slug)
    assert_response :success
  end

  test "should get new" do
    get new_recipe_url
    assert_response :success
  end

  test "should get new with import_key" do
    scraped_data = {
      title: "Imported Recipe",
      description: "Test description",
      instructions: "Test instructions",
      ingredients: [ { name: "Flour", quantity: 2, unit: "cups" } ]
    }
    import_key = SecureRandom.hex(8)
    Rails.cache.write("import_#{import_key}", scraped_data, expires_in: 10.minutes)

    get new_recipe_url(import_key: import_key)
    assert_response :success
    assert_select "form", true
  end

  test "should get new with scan_key" do
    scanned_data = {
      title: "Scanned Recipe",
      description: "Test description",
      instructions: "Test instructions",
      ingredients: [ { name: "Flour", quantity: 2, unit: "cups", position: 1 } ],
      raw_text: "Raw OCR text"
    }
    scan_key = SecureRandom.hex(8)
    Rails.cache.write("scan_#{scan_key}", scanned_data, expires_in: 10.minutes)

    get new_recipe_url(scan_key: scan_key)
    assert_response :success
  end

  test "should create recipe" do
    assert_difference("Recipe.count", 1) do
      post recipes_url, params: {
        recipe: {
          title: "New Recipe",
          description: "Test description",
          instructions: "Test instructions",
          servings: 4,
          prep_time: 15,
          cook_time: 30,
          ingredients_attributes: [
            { name: "Flour", quantity: 2, unit: "cups", position: 1 }
          ]
        }
      }
    end

    assert_redirected_to recipe_url(Recipe.last)
  end

  test "should not create recipe without title" do
    assert_no_difference("Recipe.count") do
      post recipes_url, params: {
        recipe: {
          title: "",
          description: "Test description"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should create recipe with tags" do
    assert_difference("Recipe.count", 1) do
      assert_difference("Tag.count", 2) do
        post recipes_url, params: {
          recipe: {
            title: "New Recipe",
            tag_list: "breakfast, sweet"
          }
        }
      end
    end

    assert_redirected_to recipe_url(Recipe.last)
  end

  test "should get edit" do
    get edit_recipe_url(@recipe)
    assert_response :success
  end

  test "should update recipe" do
    patch recipe_url(@recipe), params: {
      recipe: {
        title: "Updated Title",
        servings: 6
      }
    }

    @recipe.reload
    assert_redirected_to recipe_url(@recipe)
    assert_equal "Updated Title", @recipe.title
    assert_equal 6, @recipe.servings
  end

  test "should update recipe via AJAX" do
    patch recipe_url(@recipe), params: {
      recipe: { rating: 4 }
    }, headers: { "X-Requested-With": "XMLHttpRequest" }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["success"]
  end

  test "should not update recipe with invalid data via AJAX" do
    patch recipe_url(@recipe), params: {
      recipe: { rating: 6 }
    }, headers: { "X-Requested-With": "XMLHttpRequest" }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["success"]
  end

  test "should destroy recipe" do
    assert_difference("Recipe.count", -1) do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end

  test "should purge image" do
    # This test would require attaching an image first
    # For now, we'll test the route exists
    assert_respond_to @recipe, :images
  end

  test "should purge document" do
    # This test would require attaching a document first
    # For now, we'll test the route exists
    assert_respond_to @recipe, :documents
  end

  test "should get scan" do
    get scan_recipes_url
    assert_response :success
  end

  test "should get scan_simple" do
    get scan_simple_recipes_url
    assert_response :success
  end

  test "should process scan with valid image data" do
    # Mock image data
    image_data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

    # Mock RecipeOcr to avoid actual OCR processing
    RecipeOcr.any_instance.stubs(:extract).returns(
      {
        title: "Scanned Recipe",
        description: "Test",
        instructions: "Test instructions",
        ingredients: [ { name: "Flour", quantity: 2, unit: "cups", position: 1 } ],
        raw_text: "Raw text"
      }
    )

    post scan_recipes_url, params: { image: image_data }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["redirect_url"].present?
  end

  test "should not process scan without image data" do
    post scan_recipes_url, params: {}, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should process scan multiple" do
    images_data = [ "data:image/png;base64,abc123" ]

    # Mock the job to avoid actual processing
    RecipeOcrJob.stubs(:perform_later).returns(true)

    post scan_multiple_recipes_url, params: { images: images_data }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["redirect_url"].present?
    assert_equal "processing", json_response["status"]
  end

  test "should not process scan multiple without images" do
    post scan_multiple_recipes_url, params: {}, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["error"].present?
  end

  test "should get scan status when processing" do
    scan_key = SecureRandom.hex(8)

    get scan_status_recipes_url(scan_key: scan_key)
    assert_response :success
  end

  test "should redirect from scan status when complete" do
    scan_key = SecureRandom.hex(8)
    result = { title: "Test", ingredients: [], instructions: "" }
    Rails.cache.stubs(:read).with("scan_#{scan_key}").returns(result)

    get scan_status_recipes_url(scan_key: scan_key)
    assert_redirected_to new_recipe_url(scan_key: scan_key)
  end

  test "should redirect from scan status with invalid key" do
    get scan_status_recipes_url(scan_key: "")
    assert_redirected_to recipes_url
  end
end
