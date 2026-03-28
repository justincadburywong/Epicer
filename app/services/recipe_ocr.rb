require "rtesseract"
require "mini_magick"

class RecipeOcr
  class OcrError < StandardError; end

  def initialize(image)
    @image = image
  end

  def extract
    processed_images = preprocess_multiple_variants
    best_result = perform_ocr_with_fallback(processed_images)
    parse_recipe_text(best_result)
  ensure
    processed_images&.each { |img| img.destroy! if img.respond_to?(:destroy!) }
  end

  private

  def preprocess_multiple_variants
    original = MiniMagick::Image.read(@image)
    
    variants = []
    
    # Variant 1: Enhanced grayscale with deskewing for bent pages
    variant1 = original.clone
    variant1.combine_options do |c|
      c.colorspace "Gray"
      c.contrast
      c.normalize
      c.deskew "40%"  # Help with bent pages
      c.density 200  # Increased for better text clarity
      c.resize "200%"
      c.unsharp "0x1.5+1.5+0.02"  # Sharpen text
    end
    variants << variant1
    
    # Variant 2: Aggressive preprocessing for difficult images
    variant2 = original.clone
    variant2.combine_options do |c|
      c.colorspace "Gray"
      c.contrast_stretch "0%x1%"
      c.normalize
      c.deskew "40%"  # Help with bent pages
      c.threshold "70%"  # Binarization for clear text
      c.density 200
      c.resize "200%"
      c.unsharp "0x2+2+0.02"
    end
    variants << variant2
    
    # Variant 3: Conservative approach for clean images
    variant3 = original.clone
    variant3.combine_options do |c|
      c.colorspace "Gray"
      c.contrast
      c.normalize
      c.deskew "20%"  # Lighter deskewing
      c.density 150
      c.resize "150%"
    end
    variants << variant3
    
    variants
  end

  def perform_ocr_with_fallback(images)
    results = []
    
    # Try all variants with different configurations
    custom_configs = [
      nil,  # Standard config
      {
        tessedit_char_whitelist: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,()-/°¼½¾⅓⅔⅛⅙⅕⅖⅗⅘⅚\n\s",
        tessedit_pageseg_mode: "6"  # Assume uniform text block
      },
      {
        tessedit_char_whitelist: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,()-/°¼½¾⅓⅔⅛⅙⅕⅖⅗⅘⅚\n\s",
        tessedit_pageseg_mode: "3"  # Fully automatic page segmentation
      },
      {
        tessedit_char_whitelist: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,()-/°¼½¾⅓⅔⅛⅙⅕⅖⅗⅘⅚\n\s",
        tessedit_pageseg_mode: "1"  # Automatic page segmentation with OSD
      }
    ]
    
    images.each_with_index do |image, image_index|
      custom_configs.each_with_index do |config, config_index|
        text = perform_ocr(image, "eng", config)
        if text.present?
          confidence = calculate_confidence(text)
          results << { text: text, confidence: confidence, variant: "#{image_index}-#{config_index}" }
          
          # Early exit if we get excellent results
          if confidence > 0.4
            Rails.logger.info "OCR: Early exit with confidence #{confidence} using variant #{image_index}-#{config_index}"
            return text
          end
        end
      end
    end
    
    # Return the result with highest confidence
    best_result = results.max_by { |r| r[:confidence] }
    raise OcrError, "Could not extract text from image" unless best_result
    
    Rails.logger.info "OCR: Used variant #{best_result[:variant]} with confidence #{best_result[:confidence]}"
    best_result[:text]
  end

  def perform_ocr(image, language = "eng", config = nil)
    tempfile = Tempfile.new(["ocr_image", ".png"])
    image.write(tempfile.path)
    
    begin
      if config
        result = RTesseract.new(tempfile.path, lang: language, options: config)
      else
        result = RTesseract.new(tempfile.path, lang: language)
      end
      
      text = result.to_s.strip
      text.present? ? text : nil
    rescue => e
      Rails.logger.warn "OCR attempt failed: #{e.message}"
      nil
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def calculate_confidence(text)
    return 0 if text.blank?
    
    # Basic confidence calculation based on text characteristics
    confidence = 0
    
    # Length factor (longer text is generally better)
    confidence += [text.length / 100.0, 2.0].min
    
    # Recipe-specific keywords
    recipe_keywords = %w[ingredients instructions tablespoon teaspoon cup oven bake cook stir mix add salt pepper flour sugar oil butter water]
    keyword_count = recipe_keywords.count { |keyword| text.downcase.include?(keyword) }
    confidence += keyword_count * 0.5
    
    # Numbers and measurements
    measurement_patterns = text.scan(/\d+\s*(?:cup|cups|tablespoon|tablespoons|teaspoon|teaspoons|oz|lb|g|kg|ml|l)/i)
    confidence += measurement_patterns.length * 0.3
    
    # Line structure (should have multiple lines)
    lines = text.split("\n").reject(&:empty?)
    confidence += [lines.length / 10.0, 1.0].min
    
    confidence
  end

  def parse_recipe_text(text)
    lines = text.split("\n").map(&:strip).reject(&:empty?)
    
    # Try layout-based parsing first, fall back to section-based parsing
    if lines.length > 5  # Only use layout parsing for substantial content
      layout_result = parse_by_layout(lines)
      # Check if we have valid results (arrays with content)
      ingredients_valid = layout_result[:ingredients].is_a?(Array) && layout_result[:ingredients].any?
      instructions_valid = layout_result[:instructions].is_a?(String) && layout_result[:instructions].length > 10
      if ingredients_valid && instructions_valid
        Rails.logger.info "OCR: Used layout-based parsing"
        return layout_result
      end
    end
    
    # Enhanced parsing with better pattern recognition
    result = {
      title: extract_title(lines),
      description: extract_description(lines),
      ingredients: extract_ingredients(lines),
      instructions: extract_instructions(lines),
      raw_text: text
    }
    
    # Post-process to improve results
    result[:ingredients] = post_process_ingredients(result[:ingredients])
    result[:instructions] = post_process_instructions(result[:instructions])
    
    result
  end

  def parse_by_layout(lines)
    # Enhanced layout-based parsing for better ingredient/instruction separation
    title = lines.first
    
    # Enhanced ingredient patterns
    ingredient_patterns = [
      /^\d+\s*(?:cup|cups|tablespoon|tablespoons|teaspoon|teaspoons|oz|lb|g|kg|ml|l)/i,
      /^\d+\/\d+\s*(?:cup|cups|tablespoon|tablespoons|teaspoon|teaspoons)/i,
      /^\d+\s*\d+\/\d+\s*(?:cup|cups|tablespoon|tablespoons|teaspoon|teaspoons)/i,
      /^\d+\s*(?:tbsp|tsp|oz|lb|g|kg|ml|l)/i,
      /^\d+\s*[\d\/]+\s*(?:tbsp|tsp|oz|lb|g|kg|ml|l)/i,
      /^(?:pinch|dash|handful|bunch|head|stalk|sprig|can|package|slice|piece)/i,
      /^\d+\s*(?:large|medium|small)\s+(?:onion|potato|carrot|tomato|pepper|garlic|lemon|lime)/i
    ]
    
    # Enhanced instruction patterns
    instruction_patterns = [
      /^(?:preheat|heat|cook|bake|boil|simmer|stir|mix|add|pour|season|serve|cut|chop|dice|mince|grate|whisk|fold|beat|roast|grill|fry|sauté|blend|puree|mash|cream|fold|layer|spread|drizzle|sprinkle|garnish)/i,
      /\d+\s*(?:minutes?|hours?|°f|°c|degrees?)/i,
      /(?:until|when|as|while|for|about|then|next|after|once|if)/i,
      /(?:oven|stove|pan|pot|bowl|mixer|blender|sheet|dish|rack)/i,
      /(?:gently|carefully|slowly|quickly|thoroughly|well|evenly|lightly|heavily)/i
    ]
    
    # Classify each line with enhanced logic
    ingredient_lines = []
    instruction_lines = []
    other_lines = []
    
    lines[1..-1].each_with_index do |line, index|
      is_ingredient = ingredient_patterns.any? { |pattern| line.match(pattern) }
      is_instruction = instruction_patterns.any? { |pattern| line.match(pattern) }
      
      # Additional heuristics for better classification
      word_count = line.split(/\s+/).length
      char_count = line.length
      
      if is_ingredient
        ingredient_lines << { text: line, position: index, confidence: 0.8 }
      elsif is_instruction
        instruction_lines << { text: line, position: index, confidence: 0.8 }
      else
        # Use content analysis for ambiguous lines
        if word_count <= 6 && char_count <= 50 && !line.include?("and") && !line.include?("then")
          # Likely ingredient (short, specific)
          ingredient_lines << { text: line, position: index, confidence: 0.6 }
        elsif word_count >= 8 || char_count >= 60 || line.include?("and") || line.include?("then") || line.include?("until")
          # Likely instruction (longer, contains conjunctions)
          instruction_lines << { text: line, position: index, confidence: 0.6 }
        else
          # Truly ambiguous - use position-based heuristics
          other_lines << { text: line, position: index, confidence: 0.4 }
        end
      end
    end
    
    # Enhanced layout heuristics for ambiguous lines
    other_lines.each do |line|
      position = line[:position]
      text = line[:text]
      total_lines = lines.length
      
      # Position-based classification with confidence adjustment
      if position < total_lines * 0.4  # First 40% more likely ingredients
        if text.length < 40 && text.split.length <= 5
          ingredient_lines << line.merge(confidence: 0.5)
        else
          instruction_lines << line.merge(confidence: 0.3)
        end
      elsif position > total_lines * 0.6  # Last 40% more likely instructions
        instruction_lines << line.merge(confidence: 0.5)
      else  # Middle 20% - use content analysis
        if text.include?("and") || text.include?("then") || text.include?("until") || text.length > 50
          instruction_lines << line.merge(confidence: 0.4)
        else
          ingredient_lines << line.merge(confidence: 0.3)
        end
      end
    end
    
    # Sort by original position
    ingredient_lines.sort_by! { |l| l[:position] }
    instruction_lines.sort_by! { |l| l[:position] }
    
    # Extract text
    ingredients = ingredient_lines.map { |l| l[:text] }
    instructions = instruction_lines.map { |l| l[:text] }
    
    # Post-process with error handling
    begin
      processed_ingredients = post_process_ingredients(extract_ingredients_from_lines(ingredients))
      processed_instructions = post_process_instructions(instructions.join("\n"))
    rescue => e
      Rails.logger.error "OCR: Layout processing error: #{e.message}"
      # Fall back to basic processing
      processed_ingredients = ingredients.map { |ing| { name: ing, quantity: nil, unit: nil, position: 1 } }
      processed_instructions = instructions.join("\n")
    end
    
    {
      title: title,
      description: nil,
      ingredients: processed_ingredients,
      instructions: processed_instructions,
      raw_text: lines.join("\n")
    }
  end

  def extract_ingredients_from_lines(lines)
    lines.map.with_index do |line, index|
      # Try to extract quantity, unit, and name from each line
      if match = line.match(/^(\d+(?:\.\d+)?(?:\s*\d+\/\d+)?)\s*([a-zA-Z%]+)?\s*(.+)$/)
        quantity_str = match[1]
        unit = match[2]&.strip
        name = match[3]&.strip
        
        # Convert quantity to float
        quantity = if quantity_str.include?('/')
          eval(quantity_str)  # Safe for simple fractions
        else
          quantity_str.to_f
        end
        
        {
          name: name,
          quantity: quantity,
          unit: unit,
          position: index + 1
        }
      else
        {
          name: line,
          quantity: nil,
          unit: nil,
          position: index + 1
        }
      end
    end
  end

  def post_process_ingredients(ingredients)
    ingredients.map do |ingredient|
      # Fix common OCR errors
      name = ingredient[:name]
      
      # Enhanced OCR error corrections
      name = name.gsub(/l([b]|bs)/i, 'lb')  # Fix "lb" OCR errors
      name = name.gsub(/tbsps?/i, 'tablespoon')  # Fix "tbsp" variations
      name = name.gsub(/tsps?/i, 'teaspoon')   # Fix "tsp" variations
      name = name.gsub(/ozs?/i, 'ounce')       # Fix "oz" variations
      name = name.gsub(/g\s+/i, 'grams')        # Fix "g" spacing issues
      name = name.gsub(/0\s+O/i, '°')             # Fix degree symbol
      name = name.gsub(/c\s+([^a-z])/i, '\1') # Fix "c" before consonants
      name = name.gsub(/(\d+)\s*([a-z])\s*/i, '\1 \2') # Fix number-letter spacing
      name = name.gsub(/\s{2,}/, ' ')           # Normalize whitespace
      name = name.gsub(/ing$/i, '')             # Remove trailing "ing"
      
      # Extract quantities from name if they weren't caught initially
      if ingredient[:quantity].blank?
        # Enhanced quantity extraction patterns
        quantity_match = name.match(/^(\d+\/\d+)\s*(.+)/)      # 1/2 cup
        if quantity_match
          ingredient[:quantity] = quantity_match[1].to_f / quantity_match[2].to_f
          ingredient[:unit] = quantity_match[2]&.strip
          ingredient[:name] = quantity_match[3]&.strip
        elsif name.match(/^(\d+)\s*([\d\/]+)\s*(.+)/)  # Mixed numbers
          numbers = name.match(/(\d+)\s*([\d\/]+)/)
          if numbers
            whole = numbers[1].to_f
            fraction = eval(numbers[2])  # Safe eval for simple fractions
            ingredient[:quantity] = whole + fraction
            ingredient[:unit] = name.gsub(/^(\d+)\s*([\d\/]+)\s*/, '')
            ingredient[:name] = name.gsub(/^(\d+)\s*([\d\/]+)\s*/, '')
          elsif name.match(/^(\d+\.?\d*)\s*(.+)/)        # Decimals
            quantity_match = name.match(/^(\d+\.?\d*)\s*(.+)/)
            if quantity_match
              ingredient[:quantity] = quantity_match[1].to_f
              ingredient[:unit] = name.gsub(/^(\d+\.?\d*)\s*/, '')
              ingredient[:name] = quantity_match[2]&.strip
            end
          end
        end
      end
      
      ingredient[:name] = name
      ingredient
    end
  end

  def post_process_instructions(instructions)
    # Better instruction formatting
    lines = instructions.split("\n").map(&:strip).reject(&:empty?)
    
    processed_lines = lines.map do |line|
      # Remove common OCR artifacts
      line = line.gsub(/[A-Z]{2,}/, '')  # Remove random capital letters
      line = line.gsub(/\d+\s*[\.,]\s*/, '')  # Remove stray numbers with punctuation
      line = line.gsub(/\s{2,}/, ' ')  # Normalize whitespace
      
      # Ensure proper sentence case
      line = line.capitalize if line.length > 0
      line
    end
    
    processed_lines.join("\n")
  end

  def extract_title(lines)
    lines.first&.strip
  end

  def extract_description(lines)
    return nil if lines.length < 3
    
    ingredients_start = find_section_start(lines, /ingredients?/i)
    return nil unless ingredients_start && ingredients_start > 1
    
    lines[1...ingredients_start].join(" ").strip.presence
  end

  def extract_ingredients(lines)
    start_idx = find_section_start(lines, /ingredients?/i)
    return [] unless start_idx
    
    end_idx = find_section_start(lines, /instructions?|directions?|method|steps?/i, start_idx + 1) || lines.length
    
    ingredient_lines = lines[(start_idx + 1)...end_idx]
    
    # Enhanced ingredient parsing with better patterns
    ingredients = []
    
    ingredient_lines.each do |line|
      # Try multiple parsing patterns
      ingredient = parse_ingredient_line(line) || 
                  parse_ingredient_line_fallback(line) || 
                  parse_ingredient_line_simple(line)
      
      ingredients << ingredient if ingredient
    end
    
    ingredients
  end

  def parse_ingredient_line_fallback(line)
    line = line.gsub(/^[-•*]\s*/, "").strip
    return nil if line.empty?
    
    # More flexible pattern matching
    patterns = [
      # Quantity + Unit + Name (most common)
      /^([\d\/\.\s]+)\s*([a-zA-Z]+)\s+(.+)$/,
      # Quantity + Name (no unit)
      /^([\d\/\.\s]+)\s+(.+)$/,
      # Unit + Name (no quantity)
      /^([a-zA-Z]+)\s+(.+)$/,
      # Just name
      /^(.+)$/
    ]
    
    patterns.each do |pattern|
      match = line.match(pattern)
      next unless match
      
      case pattern
      when patterns[0]  # Quantity + Unit + Name
        quantity = parse_quantity(match[1])
        unit = match[2].strip
        name = match[3].strip
        
        if common_unit?(unit)
          return { quantity: quantity, unit: unit, name: name }
        else
          return { quantity: quantity, unit: nil, name: "#{unit} #{name}".strip }
        end
        
      when patterns[1]  # Quantity + Name
        quantity = parse_quantity(match[1])
        name = match[2].strip
        return { quantity: quantity, unit: nil, name: name }
        
      when patterns[2]  # Unit + Name
        unit = match[1].strip
        name = match[2].strip
        
        if common_unit?(unit)
          return { quantity: nil, unit: unit, name: name }
        else
          return { quantity: nil, unit: nil, name: "#{unit} #{name}".strip }
        end
        
      when patterns[3]  # Just name
        return { quantity: nil, unit: nil, name: line }
      end
    end
    
    nil
  end

  def parse_ingredient_line_simple(line)
    line = line.gsub(/^[-•*]\s*/, "").strip
    return nil if line.empty?
    
    { quantity: nil, unit: nil, name: line }
  end

  def extract_instructions(lines)
    start_idx = find_section_start(lines, /instructions?|directions?|method|steps?/i)
    return "" unless start_idx
    
    instruction_lines = lines[(start_idx + 1)..]
    
    instruction_lines
      .map { |line| line.gsub(/^\d+[\.\)]\s*/, "").strip }
      .reject(&:empty?)
      .join("\n")
  end

  def find_section_start(lines, pattern, from_index = 0)
    # Ensure lines is an array, not a string
    lines = lines.split("\n") if lines.is_a?(String)
    return nil unless lines.is_a?(Array)
    
    lines[from_index..].each_with_index do |line, idx|
      return from_index + idx if line.match?(pattern)
    end
    nil
  end

  def parse_ingredient_line(line)
    line = line.gsub(/^[-•*]\s*/, "").strip
    return nil if line.empty?
    
    match = line.match(/^([\d\/\.\s]+)?\s*(\w+)?\s+(.+)$/i)
    
    if match
      quantity = parse_quantity(match[1])
      unit = match[2]&.strip
      name = match[3]&.strip
      
      if common_unit?(unit)
        { quantity: quantity, unit: unit, name: name }
      else
        { quantity: quantity, unit: nil, name: "#{unit} #{name}".strip }
      end
    else
      { quantity: nil, unit: nil, name: line }
    end
  end

  def parse_quantity(str)
    return nil if str.blank?
    
    str = str.strip
    
    if str.include?("/")
      parts = str.split("/")
      return parts[0].to_f / parts[1].to_f if parts.length == 2
    end
    
    str.to_f
  end

  def common_unit?(word)
    return false if word.blank?
    
    units = %w[
      cup cups c
      tablespoon tablespoons tbsp tbs
      teaspoon teaspoons tsp
      ounce ounces oz
      pound pounds lb lbs
      gram grams g
      kilogram kilograms kg
      milliliter milliliters ml
      liter liters l
      pinch dash
      piece pieces
      slice slices
      clove cloves
      can cans
      package packages pkg
      bunch bunches
      head heads
      stalk stalks
      sprig sprigs
      large medium small
      handful handfuls
      drop drops
      quart quarts qt
      pint pints pt
      gallon gallons gal
      fluid fluid_ounce fluid_ounces fl_oz
      centimeter centimeters cm
      inch inches in
      tablespoonful tablespoonfuls
      teaspoonful teaspoonfuls
      cupful cupfuls
    ]
    
    units.include?(word.downcase)
  end
end
