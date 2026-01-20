class RecipeScraper
  class ScrapingError < StandardError; end

  def initialize(url)
    @url = url
  end

  def scrape
    response = fetch_page
    doc = Nokogiri::HTML(response.body)
    
    recipe_data = extract_json_ld(doc) || extract_microdata(doc) || extract_fallback(doc)
    
    raise ScrapingError, "Could not find recipe data on this page" if recipe_data.blank?
    
    normalize_recipe(recipe_data)
  end

  private

  def fetch_page
    response = HTTParty.get(@url, {
      headers: {
        "User-Agent" => "Mozilla/5.0 (compatible; RecipeVault/1.0)",
        "Accept" => "text/html"
      },
      follow_redirects: true,
      timeout: 10
    })
    
    raise ScrapingError, "Failed to fetch page: #{response.code}" unless response.success?
    response
  end

  def extract_json_ld(doc)
    doc.css('script[type="application/ld+json"]').each do |script|
      begin
        data = JSON.parse(script.text)
        recipe = find_recipe_in_json(data)
        return recipe if recipe
      rescue JSON::ParserError
        next
      end
    end
    nil
  end

  def find_recipe_in_json(data)
    return data if recipe_type?(data)
    
    if data.is_a?(Array)
      data.each do |item|
        result = find_recipe_in_json(item)
        return result if result
      end
    elsif data.is_a?(Hash)
      if data["@graph"]
        return find_recipe_in_json(data["@graph"])
      end
    end
    
    nil
  end

  def recipe_type?(data)
    return false unless data.is_a?(Hash)
    type = data["@type"]
    type == "Recipe" || (type.is_a?(Array) && type.include?("Recipe"))
  end

  def extract_microdata(doc)
    recipe_node = doc.at('[itemtype*="schema.org/Recipe"]')
    return nil unless recipe_node

    {
      "name" => recipe_node.at('[itemprop="name"]')&.text,
      "description" => recipe_node.at('[itemprop="description"]')&.text,
      "recipeIngredient" => recipe_node.css('[itemprop="recipeIngredient"], [itemprop="ingredients"]').map(&:text),
      "recipeInstructions" => recipe_node.css('[itemprop="recipeInstructions"]').map(&:text),
      "prepTime" => recipe_node.at('[itemprop="prepTime"]')&.[]("content"),
      "cookTime" => recipe_node.at('[itemprop="cookTime"]')&.[]("content"),
      "recipeYield" => recipe_node.at('[itemprop="recipeYield"]')&.text
    }
  end

  def extract_fallback(doc)
    title = doc.at("h1")&.text&.strip
    return nil if title.blank?

    {
      "name" => title,
      "description" => doc.at('meta[name="description"]')&.[]("content")
    }
  end

  def normalize_recipe(data)
    {
      title: clean_text(data["name"]),
      description: clean_text(data["description"]),
      source_url: @url,
      prep_time: parse_duration(data["prepTime"]),
      cook_time: parse_duration(data["cookTime"]),
      servings: parse_servings(data["recipeYield"]),
      instructions: normalize_instructions(data["recipeInstructions"]),
      ingredients: normalize_ingredients(data["recipeIngredient"])
    }
  end

  def clean_text(text)
    return nil if text.blank?
    text.to_s.strip.gsub(/\s+/, " ")
  end

  def parse_duration(duration)
    return nil if duration.blank?
    
    if duration =~ /PT(\d+)H(\d+)M/
      $1.to_i * 60 + $2.to_i
    elsif duration =~ /PT(\d+)H/
      $1.to_i * 60
    elsif duration =~ /PT(\d+)M/
      $1.to_i
    elsif duration =~ /(\d+)\s*min/i
      $1.to_i
    end
  end

  def parse_servings(yield_str)
    return nil if yield_str.blank?
    yield_str.to_s.scan(/\d+/).first&.to_i
  end

  def normalize_instructions(instructions)
    return nil if instructions.blank?

    steps = case instructions
    when String
      instructions.split(/\n+/)
    when Array
      instructions.flat_map do |item|
        if item.is_a?(Hash)
          item["text"] || item["itemListElement"]&.map { |i| i["text"] }
        else
          item.to_s
        end
      end
    else
      []
    end

    steps.compact.map { |s| clean_text(s) }.reject(&:blank?).join("\n\n")
  end

  def normalize_ingredients(ingredients)
    return [] if ingredients.blank?
    
    ingredients.map do |ing|
      text = clean_text(ing)
      next if text.blank?
      parse_ingredient(text)
    end.compact
  end

  def parse_ingredient(text)
    quantity = nil
    unit = nil
    name = text

    if text =~ /^([\d\s\/\.]+)\s*(cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lbs?|pounds?|g|grams?|kg|ml|liters?|quarts?|pints?|gallons?|cloves?|pieces?|slices?|cans?|packages?|sticks?)?\s*(.+)/i
      quantity = parse_quantity($1)
      unit = $2&.strip&.downcase
      name = $3.strip
    end

    { name: name, quantity: quantity, unit: unit }
  end

  def parse_quantity(str)
    return nil if str.blank?
    
    str = str.strip
    
    if str =~ /(\d+)\s*\/\s*(\d+)/
      return $1.to_f / $2.to_f
    end
    
    if str =~ /(\d+)\s+(\d+)\s*\/\s*(\d+)/
      return $1.to_i + ($2.to_f / $3.to_f)
    end
    
    str.to_f if str =~ /^\d/
  end
end
