class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy purge_image purge_document]

  def index
    @recipes = Recipe.search(params[:query]).order(created_at: :desc)
    
    if params[:tag].present?
      @recipes = @recipes.joins(:tags).where(tags: { name: params[:tag] })
      @current_tag = params[:tag]
    end
    
    @all_tags = Tag.popular.limit(20)
  end

  def show
  end

  def new
    if params[:import_key].present?
      scraped = Rails.cache.read("import_#{params[:import_key]}")
      if scraped.present?
        scraped = scraped.deep_symbolize_keys
        Rails.cache.delete("import_#{params[:import_key]}")
        @recipe = Recipe.new(scraped.except(:ingredients, :image_url))
        
        # Store image_url in session for attachment after recipe is saved
        session[:pending_image_url] = scraped[:image_url] if scraped[:image_url].present?
        
        scraped[:ingredients]&.each_with_index do |ing, index|
          @recipe.ingredients.build(ing.merge(position: index + 1))
        end
        return
      end
    elsif params[:scan_key].present?
      scanned = Rails.cache.read("scan_#{params[:scan_key]}")
      if scanned.present?
        scanned = scanned.deep_symbolize_keys
        Rails.cache.delete("scan_#{params[:scan_key]}")
        @recipe = Recipe.new(
          title: scanned[:title],
          description: scanned[:description],
          instructions: scanned[:instructions]
        )
        
        scanned[:ingredients]&.each_with_index do |ing, index|
          @recipe.ingredients.build(ing.merge(position: index + 1))
        end
        
        @raw_ocr_text = scanned[:raw_text]
        return
      end
    end
    
    @recipe = Recipe.new
    @recipe.ingredients.build
  end

  def import
    if request.post?
      url = params[:url]&.strip
      
      if url.blank?
        flash.now[:alert] = "Please enter a URL"
        return render :import, status: :unprocessable_entity
      end

      begin
        scraped = RecipeScraper.new(url).scrape
        import_key = SecureRandom.hex(8)
        Rails.cache.write("import_#{import_key}", scraped, expires_in: 10.minutes)
        redirect_to new_recipe_path(import_key: import_key), notice: "Recipe imported! Review and save below."
      rescue RecipeScraper::ScrapingError => e
        flash.now[:alert] = e.message
        render :import, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error("Scraping failed: #{e.message}")
        flash.now[:alert] = "Failed to import recipe. Please try again or add manually."
        render :import, status: :unprocessable_entity
      end
    end
  end

  def crop_image
    @recipe = Recipe.new
    if params[:image].present?
      # Store the uploaded image temporarily for cropping
      @recipe.images.attach(params[:image])
      @image_to_crop = @recipe.images.first
      render :crop
    else
      redirect_to new_recipe_path, alert: "Please select an image to crop"
    end
  end

  def process_ocr_with_crop
    @recipe = Recipe.new(recipe_params)
    
    if params[:crop_coords].present? && @recipe.images.attached?
      # Crop the image before OCR processing
      image = @recipe.images.first
      crop_coords = params[:crop_coords]
      
      # Apply crop using MiniMagick
      cropped_image = crop_image_for_ocr(image, crop_coords)
      
      # Process OCR on cropped image
      ocr_result = RecipeOcr.new(cropped_image.path).extract
      
      @raw_ocr_text = ocr_result[:raw_text]
      @recipe = Recipe.new(ocr_result.except(:raw_text))
      
      # Replace the original image with cropped version
      @recipe.images.detach
      @recipe.images.attach(io: File.open(cropped_image.path), filename: "cropped_#{image.filename}")
      
      render :new
    else
      redirect_to new_recipe_path, alert: "Please crop the image first"
    end
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      # Attach feature image if there's a pending image_url from session
      if session[:pending_image_url].present?
        Rails.logger.info "Attaching pending image: #{session[:pending_image_url]}"
        downloaded_image = RecipeScraper.new(@recipe.source_url).download_image(session[:pending_image_url])
        if downloaded_image.present?
          @recipe.feature_image.attach(downloaded_image)
          Rails.logger.info "Successfully attached feature_image to recipe #{@recipe.id}"
        else
          Rails.logger.warn "Failed to download pending image from #{session[:pending_image_url]}"
        end
        session.delete(:pending_image_url)
      end
      
      redirect_to @recipe, notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: "Recipe was successfully deleted."
  end

  def purge_image
    image = @recipe.images.find(params[:image_id])
    image.purge
    redirect_to edit_recipe_path(@recipe), notice: "Image removed."
  end

  def purge_document
    document = @recipe.documents.find(params[:document_id])
    document.purge
    redirect_to edit_recipe_path(@recipe), notice: "Document removed."
  end

  def scan
  end

  def scan_simple
  end

  def process_scan
    image_data = params[:image]
    
    if image_data.blank?
      return render json: { error: "No image provided" }, status: :unprocessable_entity
    end

    begin
      image_binary = Base64.decode64(image_data.sub(/^data:image\/\w+;base64,/, ""))
      
      result = RecipeOcr.new(image_binary).extract
      
      scan_key = SecureRandom.hex(8)
      Rails.cache.write("scan_#{scan_key}", result, expires_in: 10.minutes)
      
      render json: { redirect_url: new_recipe_path(scan_key: scan_key) }
    rescue RecipeOcr::OcrError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("OCR failed: #{e.message}")
      render json: { error: "Failed to process image. Please try again." }, status: :unprocessable_entity
    end
  end

  def process_scan_multiple
    images_data = params[:images]
    
    if images_data.blank?
      return render json: { error: "No images provided" }, status: :unprocessable_entity
    end

    begin
      scan_key = SecureRandom.hex(8)
      
      # Enqueue background job for OCR processing
      RecipeOcrJob.perform_later(images_data, scan_key)
      
      render json: { 
        redirect_url: "/recipes/scan_status?scan_key=#{scan_key}",
        message: "Processing your recipe images... This may take a moment.",
        status: "processing"
      }
    rescue StandardError => e
      Rails.logger.error("OCR job failed to start: #{e.message}")
      render json: { error: "Failed to start image processing. Please try again." }, status: :unprocessable_entity
    end
  end

  def scan_status
    scan_key = params[:scan_key]
    
    if scan_key.blank?
      return redirect_to recipes_path, alert: "Invalid scan session"
    end
    
    # Check if processing is complete
    result = Rails.cache.read("scan_#{scan_key}")
    
    if result
      # Processing complete, redirect to recipe form
      redirect_to new_recipe_path(scan_key: scan_key)
    else
      # Still processing, show status page
      render :scan_status
    end
  end

  private

  def set_recipe
    @recipe = Recipe.friendly.find(params[:id])
  end

  def crop_image_for_ocr(image, crop_coords)
    # Parse crop coordinates (x, y, width, height)
    x = crop_coords[:x].to_i
    y = crop_coords[:y].to_i
    width = crop_coords[:width].to_i
    height = crop_coords[:height].to_i
    
    # Open the original image
    original_image = MiniMagick::Image.read(image.blob.service.send(:download))
    
    # Apply crop
    cropped = original_image.crop("#{width}x#{height}+#{x}+#{y}")
    
    # Save to temporary file
    temp_file = Tempfile.new(["cropped_ocr", ".jpg"])
    cropped.write(temp_file.path)
    
    temp_file
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :instructions, :source_url, :image_url,
      :prep_time, :cook_time, :servings, :rating, :notes, :tag_list,
      images: [], documents: [],
      ingredients_attributes: %i[id name quantity unit position _destroy]
    )
  end
end
