# Epicer Recipe App - Testing Guide

## Overview

This document describes the comprehensive test suite for the Epicer recipe application. The test suite follows Test-Driven Development (TDD) principles to ensure the application is correctly specified and free of odd behaviors.

## Test Structure

### Unit Tests (Model Tests)

Location: `test/models/`

#### Recipe Model (`recipe_test.rb`)
- **Validation Tests:**
  - Title presence validation
  - Rating range validation (1-5)
  - Servings validation (must be > 0)
  - Prep time and cook time non-negative validation
  - Nil value handling for optional fields

- **Association Tests:**
  - Has many ingredients ordered by position
  - Dependent destroy of ingredients
  - Tag management through tag_list getter/setter
  - Nested attributes for ingredients

- **Scope Tests:**
  - Search functionality (title, description, instructions)
  - Case-insensitive search
  - Blank query handling

- **Method Tests:**
  - total_time calculation
  - Friendly ID slug generation
  - display_image method
  - tag_list normalization and deduplication

#### Ingredient Model (`ingredient_test.rb`)
- **Validation Tests:**
  - Name presence validation
  - Quantity validation (must be > 0)
  - Nil quantity handling

- **Association Tests:**
  - Belongs to recipe
  - Position ordering

- **Method Tests:**
  - scaled_quantity calculation for different serving sizes
  - display_quantity formatting (whole numbers, decimals, fractions, mixed numbers)
  - parse_quantity class method (whole numbers, decimals, fractions, mixed numbers)

#### Tag Model (`tag_test.rb`)
- **Validation Tests:**
  - Name presence validation
  - Case-insensitive uniqueness
  - Name normalization (titleize)

- **Association Tests:**
  - Has many recipes through recipe_tags
  - Dependent destroy of recipe_tags

- **Scope Tests:**
  - Popular scope (orders by recipe count)

#### RecipeTag Model (`recipe_tag_test.rb`)
- **Validation Tests:**
  - Recipe presence
  - Tag presence
  - Uniqueness of recipe-tag combination

- **Association Tests:**
  - Allows same tag for different recipes
  - Allows same recipe with different tags

### Controller Tests (Integration Tests)

Location: `test/controllers/recipes_controller_test.rb`

#### CRUD Operations
- Index page with search and tag filtering
- Show page with friendly ID support
- New page with import_key and scan_key support
- Create with valid and invalid data
- Update with regular and AJAX requests
- Destroy operation

#### OCR/Scan Features
- Scan page rendering
- Process scan with valid image data (mocked)
- Process scan error handling
- Multiple image scan processing (mocked job)
- Scan status checking and redirects

#### Image/Document Management
- Purge image route
- Purge document route

### System Tests (End-to-End Tests)

Location: `test/system/recipes_system_test.rb`

#### User Flows
- Visiting the index page
- Creating a recipe with basic fields
- Creating a recipe with ingredients
- Creating a recipe with tags
- Viewing a recipe
- Updating a recipe
- Deleting a recipe
- Searching recipes
- Filtering by tags
- Navigating to scan page

## Running Tests

### Run All Tests
```bash
bin/rails test
```

### Run Specific Test File
```bash
bin/rails test test/models/recipe_test.rb
```

### Run Specific Test
```bash
bin/rails test test/models/recipe_test.rb:10
```

### Run Model Tests Only
```bash
bin/rails test test/models
```

### Run Controller Tests Only
```bash
bin/rails test test/controllers
```

### Run System Tests Only
```bash
bin/rails test test/system
```

### Run Tests with Verbose Output
```bash
bin/rails test --verbose
```

## Test Dependencies

The test suite uses the following gems (added to Gemfile):

- `mocha` - For mocking and stubbing in tests
- `capybara` - For system/end-to-end testing
- `selenium-webdriver` - Browser automation for system tests

## Fixtures

Test fixtures are located in `test/fixtures/`:

- `recipes.yml` - Sample recipe data
- `ingredients.yml` - Sample ingredient data
- `tags.yml` - Sample tag data
- `recipe_tags.yml` - Sample recipe-tag associations

## Test Configuration

The test suite is configured in `test/test_helper.rb`:

- Parallel test execution enabled
- All fixtures loaded automatically
- Mocha integration for mocking

## Model Validations Added

### RecipeTag Model
Added validation to prevent duplicate recipe-tag associations:
```ruby
validates :recipe_id, uniqueness: { scope: :tag_id }
```

## Continuous Testing

For TDD workflow, you can use guard or watch tools to automatically run tests when files change:

```bash
# Install guard-rails (optional)
gem install guard-rails

# Run guard
guard
```

## Test Coverage Goals

The test suite aims to cover:

- ✅ All model validations
- ✅ All model associations
- ✅ All model methods and scopes
- ✅ All controller actions
- ✅ Error handling paths
- ✅ AJAX endpoints
- ✅ OCR/scan workflows (with mocking)
- ✅ Key user flows (system tests)

## Questions?

If you have questions about the test suite or need additional test coverage for specific features, please ask!

## Next Steps

1. Install test dependencies: `bundle install`
2. Run the test suite: `bin/rails test`
3. Review any failing tests and fix issues
4. Add more tests as new features are developed
5. Maintain test coverage above 80% (goal)
