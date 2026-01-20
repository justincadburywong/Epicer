require "rtesseract"
require "mini_magick"

class RecipeOcr
  class OcrError < StandardError; end

  def initialize(image)
    @image = image
  end

  def extract
    processed_image = preprocess_image
    text = perform_ocr(processed_image)
    parse_recipe_text(text)
  ensure
    processed_image&.destroy! if processed_image.respond_to?(:destroy!)
  end

  private

  def preprocess_image
    image = MiniMagick::Image.read(@image)
    
    image.combine_options do |c|
      c.colorspace "Gray"
      c.contrast
      c.sharpen "0x1"
      c.density 300
    end
    
    image
  end

  def perform_ocr(image)
    tempfile = Tempfile.new(["ocr_image", ".png"])
    image.write(tempfile.path)
    
    result = RTesseract.new(tempfile.path, lang: "eng")
    text = result.to_s
    
    tempfile.close
    tempfile.unlink
    
    raise OcrError, "Could not extract text from image" if text.strip.empty?
    
    text
  end

  def parse_recipe_text(text)
    lines = text.split("\n").map(&:strip).reject(&:empty?)
    
    {
      title: extract_title(lines),
      description: extract_description(lines),
      ingredients: extract_ingredients(lines),
      instructions: extract_instructions(lines),
      raw_text: text
    }
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
    
    ingredient_lines.map do |line|
      parse_ingredient_line(line)
    end.compact
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
    ]
    
    units.include?(word.downcase)
  end
end
