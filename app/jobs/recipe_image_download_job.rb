class RecipeImageDownloadJob < ApplicationJob
  queue_as :default

  def perform(recipe_id, image_url, source_url)
    return if image_url.blank?
    
    recipe = Recipe.find_by(id: recipe_id)
    return unless recipe
    
    begin
      Rails.logger.info "Starting background image download for recipe #{recipe_id}: #{image_url}"
      
      scraper = RecipeScraper.new(source_url)
      downloaded_image = scraper.download_image(image_url)
      
      if downloaded_image.present?
        recipe.feature_image.attach(downloaded_image)
        Rails.logger.info "Successfully attached feature_image to recipe #{recipe_id} in background job"
      else
        Rails.logger.warn "Failed to download image for recipe #{recipe_id}: #{image_url}"
      end
    rescue => e
      Rails.logger.error "Error in RecipeImageDownloadJob for recipe #{recipe_id}: #{e.class} - #{e.message}"
    end
  end
end
