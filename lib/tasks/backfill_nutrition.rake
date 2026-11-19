namespace :nutrition do
  desc "Update nutrition data for all recipes"
  task backfill: :environment do
    all_recipes = Recipe.all
    total = all_recipes.count

    if total.zero?
      puts "No recipes found."
      return
    end

    puts "Found #{total} recipes. Starting nutrition update..."
    puts "=" * 50

    success_count = 0
    scraped_count = 0
    calculated_count = 0
    error_count = 0

    all_recipes.find_each(batch_size: 100) do |recipe|
      begin
        nutrition_data = nil

        # First try to scrape nutrition from source URL if available
        if recipe.source_url.present?
          begin
            scraper = RecipeScraper.new(recipe.source_url)
            scraped_data = scraper.scrape
            if scraped_data[:nutrition].present?
              nutrition_data = scraped_data[:nutrition]
              scraped_count += 1
              puts "[#{success_count + 1}/#{total}] ✓ #{recipe.title} (scraped)"
            end
          rescue RecipeScraper::ScrapingError => e
            puts "[SKIPPED] Could not scrape nutrition for '#{recipe.title}': #{e.message}"
          rescue => e
            puts "[SKIPPED] Error scraping '#{recipe.title}': #{e.message}"
          end
        end

        # Fall back to calculator if scraping failed or no source URL
        if nutrition_data.nil?
          calculator = NutritionCalculator.new(recipe)
          nutrition_data = calculator.calculate
          calculated_count += 1
          puts "[#{success_count + 1}/#{total}] ✓ #{recipe.title} (calculated)"
        end

        # Update or create nutrition record
        if recipe.nutrition.present?
          recipe.nutrition.update(
            calories: nutrition_data[:calories],
            carbohydrates: nutrition_data[:carbohydrates],
            cholesterol: nutrition_data[:cholesterol],
            sodium: nutrition_data[:sodium],
            fat: nutrition_data[:fat],
            protein: nutrition_data[:protein]
          )
        else
          recipe.create_nutrition!(
            calories: nutrition_data[:calories],
            carbohydrates: nutrition_data[:carbohydrates],
            cholesterol: nutrition_data[:cholesterol],
            sodium: nutrition_data[:sodium],
            fat: nutrition_data[:fat],
            protein: nutrition_data[:protein]
          )
        end

        success_count += 1
      rescue => e
        error_count += 1
        puts "[ERROR] Failed to process '#{recipe.title}': #{e.message}"
        Rails.logger.error "Nutrition backfill failed for recipe #{recipe.id}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    puts "=" * 50
    puts "Nutrition update complete!"
    puts "Successfully processed: #{success_count}"
    puts "  - Scraped from source: #{scraped_count}"
    puts "  - Calculated from ingredients: #{calculated_count}"
    puts "Errors: #{error_count}"
  end
end
