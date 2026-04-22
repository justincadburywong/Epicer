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
      timeout: 10,
      ssl_ca_file: ssl_ca_file,
      verify: ssl_verify_mode,
      verify_peer: ssl_verify_mode
    })
    
    raise ScrapingError, "Failed to fetch page: #{response.code}" unless response.success?
    response
  end

  def ssl_ca_file
    # Try common certificate locations
    [
      ENV["SSL_CERT_FILE"],
      "/etc/ssl/cert.pem",
      "/usr/local/etc/ca-certificates/cert.pem",
      "/usr/local/etc/openssl@3/cert.pem"
    ].compact.find { |f| File.exist?(f) }
  end

  def ssl_verify_mode
    ENV["SCRAPER_SKIP_SSL_VERIFY"] == "true" ? false : true
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

  public
  
  def normalize_recipe(data)
    {
      title: decode_html_entities(data["name"] || ""),
      description: decode_html_entities(data["description"] || ""),
      source_url: @url,
      image_url: extract_image_url(data),
      prep_time: parse_time(data["prepTime"] || data["totalTime"]),
      cook_time: parse_time(data["cookTime"]),
      servings: parse_servings(data["recipeYield"] || data["recipeCuisine"]),
      instructions: normalize_instructions(data["recipeInstructions"]),
      ingredients: normalize_ingredients(data["recipeIngredient"])
    }
  end

  def decode_html_entities(text)
    return "" if text.blank?
    
    # Decode common HTML entities
    text = text.to_s
      .gsub(/&#39;/, "'")
      .gsub(/&quot;/, '"')
      .gsub(/&amp;/, '&')
      .gsub(/&lt;/, '<')
      .gsub(/&gt;/, '>')
      .gsub(/&nbsp;/, ' ')
      .gsub(/&#34;/, '"')
      .gsub(/&#38;/, '&')
      .gsub(/&#60;/, '<')
      .gsub(/&#62;/, '>')
      .strip
    
    text
  end

  def clean_text(text)
    return nil if text.blank?
    text.to_s.strip.gsub(/\s+/, " ")
  end

  def parse_time(duration)
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
    return [] if instructions.blank?
    
    result = extract_instruction_steps(instructions)

    result.compact.map { |s| clean_text(s) }.reject(&:blank?).join("\n\n")
  end

  def extract_instruction_steps(instructions)
    return [] if instructions.blank?

    if instructions.is_a?(Array)
      instructions.flat_map { |instruction| extract_instruction_steps(instruction) }
    elsif instructions.is_a?(Hash)
      # Handle HowToSection with nested itemListElement
      if instructions["@type"] == "HowToSection" && instructions["itemListElement"]
        section_name = instructions["name"]
        steps = extract_instruction_steps(instructions["itemListElement"])
        section_name.present? ? ["**#{decode_html_entities(section_name)}**"] + steps : steps
      elsif instructions["text"]
        [decode_html_entities(instructions["text"])]
      else
        []
      end
    elsif instructions.is_a?(String)
      [decode_html_entities(instructions)]
    else
      []
    end
  end

  def normalize_ingredients(ingredients)
    return [] if ingredients.blank?
    
    if ingredients.is_a?(Array)
      ingredients.map do |ingredient|
        if ingredient.is_a?(Hash)
          {
            name: decode_html_entities(ingredient["name"] || ""),
            quantity: parse_quantity(ingredient["quantity"]),
            unit: decode_html_entities(ingredient["unit"] || "")
          }
        else
          {
            name: decode_html_entities(ingredient.to_s),
            quantity: nil,
            unit: ""
          }
        end
      end
    else
      []
    end
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

  def extract_image_url(data)
    # Try multiple methods to find the main recipe image
    image_url = nil
    
    # Method 1: Check for structured data image
    if data["image"]
      image_url = data["image"]
    elsif data["thumbnailUrl"]
      image_url = data["thumbnailUrl"]
    end
    
    # Handle case where image_url is an array (multiple images)
    if image_url.is_a?(Array)
      # Take the first image from the array
      image_url = image_url.first
    end
    
    # Handle case where image_url is a hash (ImageObject)
    if image_url.is_a?(Hash)
      # Extract the URL from ImageObject
      image_url = image_url["url"]
    end
    
    # Method 2: Extract from page content (fallback)
    if image_url.blank?
      response = fetch_page
      doc = Nokogiri::HTML(response.body)
      
      # Look for common recipe image selectors in priority order
      image_selectors = [
        'meta[property="og:image"]',           # Open Graph image (highest priority)
        'meta[name="twitter:image"]',         # Twitter card image
        '.wprm-recipe-image img',             # WP Recipe Maker image
        '.aligncenter.size-large img',         # Main article image
        'img[alt*="recipe"]',
        'img[alt*="food"]', 
        'img[class*="recipe"]',
        'img[src*="recipe"]',
        '.recipe-image img',
        '.featured-image img',
        'article img:first-of-type'
      ]
      
      image_selectors.each do |selector|
        element = doc.at(selector)
        if element && element['src']
          image_url = element['src']
          break
        elsif element && element['content']
          image_url = element['content']
          break
        end
      end
    end
    
    # Clean up relative URLs
    if image_url && image_url.is_a?(String) && !image_url.start_with?('http')
      base_uri = URI.parse(@url)
      image_uri = URI.join(base_uri, encode_uri(image_url)) rescue image_url
      image_url = image_uri.to_s
    end
    
    # Test if the image is downloadable, if not try to find alternatives
    if image_url.present?
      test_download = try_download_simple(image_url)
      if test_download.nil?
        Rails.logger.warn "Primary image not downloadable, searching for alternatives..."
        image_url = find_alternative_image
      end
    end
    
    image_url
  end
  
  def find_alternative_image
    response = fetch_page
    doc = Nokogiri::HTML(response.body)
    
    # Try alternative selectors that might have more accessible images
    alternative_selectors = [
      'img[src*="/wp-content/"]',             # WordPress content images
      'img[src*="/uploads/"]',                # Upload directories
      'img[class*="attachment"]',            # WordPress attachment images
      'img[class*="size-"]',                 # Sized images
      '.entry-content img:first-of-type',     # First image in content
      '.post-content img:first-of-type',      # First image in post content
    ]
    
    alternative_selectors.each do |selector|
      elements = doc.css(selector)
      elements.each do |element|
        if element['src']
          alt_url = element['src']
          # Clean up relative URLs
          if !alt_url.start_with?('http')
            base_uri = URI.parse(@url)
            alt_url = URI.join(base_uri, encode_uri(alt_url)).to_s rescue alt_url
          end
          
          # Test if this alternative image is downloadable
          test_download = try_download_simple(alt_url)
          if test_download
            Rails.logger.info "Found downloadable alternative image: #{alt_url}"
            return alt_url
          end
        end
      end
    end
    
    Rails.logger.warn "No downloadable alternative images found"
    nil
  end
  
  public
  
  def download_image(image_url)
    begin
      Rails.logger.info "Attempting to download image from: #{image_url}"
      
      # Try with browser headers first
      downloaded = try_download_with_headers(image_url)
      return downloaded if downloaded
      
      # If that fails, try without headers
      Rails.logger.info "Retrying without headers..."
      downloaded = try_download_simple(image_url)
      return downloaded if downloaded
      
      # If both fail, return nil
      Rails.logger.warn "All download attempts failed for: #{image_url}"
      nil
    rescue => e
      Rails.logger.error "Failed to download image from #{image_url}: #{e.class} - #{e.message}"
      nil
    end
  end
  
  def try_download_with_headers(image_url)
    uri = URI.parse(encode_uri(image_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.request_uri)
    
    # Add headers to mimic a browser request
    request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    request['Accept'] = 'image/webp,image/apng,image/*,*/*;q=0.8'
    request['Accept-Language'] = 'en-US,en;q=0.9'
    request['Referer'] = @url
    
    response = http.request(request)
    Rails.logger.info "Headers method - HTTP Response Code: #{response.code}"
    
    if response.code.to_i == 200
      create_temp_file(response, uri)
    else
      nil
    end
  end
  
  def try_download_simple(image_url)
    uri = URI.parse(encode_uri(image_url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    request = Net::HTTP::Get.new(uri.request_uri)
    
    response = http.request(request)
    Rails.logger.info "Simple method - HTTP Response Code: #{response.code}"
    
    if response.code.to_i == 200
      create_temp_file(response, uri)
    else
      nil
    end
  end
  
  def create_temp_file(response, uri)
    temp_file = Tempfile.new(['recipe_image', '.jpg'])
    temp_file.binmode
    temp_file.write(response.body)
    temp_file.rewind
    
    {
      io: temp_file,
      filename: File.basename(uri.path) || 'recipe_image.jpg',
      content_type: response['content-type'] || 'image/jpeg'
    }
  end

  def encode_uri(url)
    return url if url.nil? || url.ascii_only?
    
    # Parse the URL, encode non-ASCII characters in the path
    uri = URI.parse(url)
    uri.path = URI::DEFAULT_PARSER.escape(uri.path)
    uri.to_s
  rescue URI::InvalidURIError
    # If parsing fails, encode the entire URL path portion
    URI::DEFAULT_PARSER.escape(url)
  end
end
