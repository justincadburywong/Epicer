class RecipeOcrJob < ApplicationJob
  queue_as :default

  def perform(images_data, scan_key)
    Rails.logger.info "Starting OCR job for scan_key: #{scan_key} with #{images_data.length} images"
    
    combined_result = {
      title: nil,
      description: nil,
      ingredients: [],
      instructions: nil,
      raw_text: ""
    }
    
    images_data.each_with_index do |image_data, index|
      Rails.logger.info "Processing image #{index + 1}/#{images_data.length}"
      
      begin
        # Decode base64 image
        image_binary = Base64.decode64(image_data.sub(/^data:image\/\w+;base64,/, ""))
        
        # Process OCR
        result = RecipeOcr.new(image_binary).extract
        
        # Combine results
        if index == 0
          # First image sets the base
          combined_result[:title] = result[:title]
          combined_result[:description] = result[:description]
          combined_result[:ingredients] = result[:ingredients]
          combined_result[:instructions] = result[:instructions]
        else
          # Subsequent images add to the result
          # Combine ingredients (avoid duplicates)
          result[:ingredients].each do |ingredient|
            unless combined_result[:ingredients].any? { |existing| 
              existing[:name].downcase.strip == ingredient[:name].downcase.strip 
            }
              combined_result[:ingredients] << ingredient
            end
          end
          
          # Combine instructions
          if result[:instructions].present?
            if combined_result[:instructions].blank?
              combined_result[:instructions] = result[:instructions]
            else
              combined_result[:instructions] += "\n\n#{result[:instructions]}"
            end
          end
        end
        
        # Combine raw text for reference
        if result[:raw_text].present?
          combined_result[:raw_text] += "\n\n--- Page #{index + 1} ---\n#{result[:raw_text]}"
        end
        
        Rails.logger.info "Completed processing image #{index + 1}"
        
      rescue RecipeOcr::OcrError => e
        Rails.logger.error "OCR failed for image #{index + 1}: #{e.message}"
        # Continue with other images
      end
    end
    
    # Cache the result
    Rails.cache.write("scan_#{scan_key}", combined_result, expires_in: 30.minutes)
    
    Rails.logger.info "OCR job completed for scan_key: #{scan_key}"
  end
end
