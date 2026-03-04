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
    
    # Variant 1: Enhanced grayscale with contrast
    variant1 = original.clone
    variant1.combine_options do |c|
      c.colorspace "Gray"
      c.contrast
      c.normalize
      c.sharpen "0x1"
      c.density 300
      c.resize "200%"  # Upscale for better OCR
      c.unsharp "0x1.5+1.5+0.02"
    end
    variants << variant1
    
    # Variant 2: Aggressive preprocessing for difficult text
    variant2 = original.clone
    variant2.combine_options do |c|
      c.colorspace "Gray"
      c.contrast_stretch "0%x1%"
      c.normalize
      c.threshold "65%"
      c.density 300
      c.resize "250%"
      c.deskew "40%"
    end
    variants << variant2
    
    # Variant 3: Gentle preprocessing for clean text
    variant3 = original.clone
    variant3.combine_options do |c|
      c.colorspace "Gray"
      c.contrast
      c.density 300
      c.resize "150%"
    end
    variants << variant3
    
    variants
  end

  def perform_ocr_with_fallback(images)
    results = []
    
    # Try each variant with different OCR configurations
    images.each_with_index do |image, index|
      # Configuration 1: Standard
      text1 = perform_ocr(image, "eng", nil)
      results << { text: text1, confidence: calculate_confidence(text1), variant: "#{index}-1" } if text1.present?
      
      # Configuration 2: With custom config for better ingredient recognition
      custom_config = {
        tessedit_char_whitelist: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,()-/°¼½¾⅓⅔⅛⅙⅕⅖⅗⅘⅚\n\s",
        tessedit_pageseg_mode: "6"  # Assume uniform text block
      }
      text2 = perform_ocr(image, "eng", custom_config)
      results << { text: text2, confidence: calculate_confidence(text2), variant: "#{index}-2" } if text2.present?
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
          end
        elsif name.match(/^(\d+\.?\d*)\s*(.+)/)        # Decimals
          quantity_match = name.match(/^(\d+\.?\d*)\s*(.+)/)
          if quantity_match
            ingredient[:quantity] = quantity_match[1].to_f
            ingredient[:unit] = name.gsub(/^(\d+\.?\d*)\s*/, '')
            ingredient[:name] = quantity_match[2]&.strip
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
