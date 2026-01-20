class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy purge_image purge_document]

  def index
    @recipes = Recipe.search(params[:query]).order(created_at: :desc)
  end

  def show
  end

  def new
    if params[:import_key].present?
      scraped = Rails.cache.read("import_#{params[:import_key]}")
      if scraped.present?
        scraped = scraped.deep_symbolize_keys
        Rails.cache.delete("import_#{params[:import_key]}")
        @recipe = Recipe.new(scraped.except(:ingredients))
        
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

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
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

  private

  def set_recipe
    @recipe = Recipe.friendly.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :instructions, :source_url,
      :prep_time, :cook_time, :servings, :rating, :notes,
      images: [], documents: [],
      ingredients_attributes: %i[id name quantity unit position _destroy]
    )
  end
end
