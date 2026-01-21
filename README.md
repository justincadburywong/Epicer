# Epicer 🍳

A personal recipe management app built with Rails 8 and Hotwire. Store, organize, and cook your favorite recipes with ease.

## Features

- **Recipe Management** - Create, edit, and organize your recipes with ingredients, instructions, prep/cook times, and servings
- **Import from URL** - Paste a recipe URL and automatically extract the recipe data using JSON-LD structured data
- **Scan from Photo** - Take a photo of a printed recipe and extract text using OCR (Tesseract)
- **Image & Document Uploads** - Attach photos of your dishes and PDF documents to recipes
- **Star Ratings & Notes** - Rate your recipes and add personal notes and modifications
- **Search** - Quickly find recipes by keyword across titles, descriptions, and instructions
- **Serving Size Adjustment** - Dynamically scale ingredient quantities for different serving sizes
- **Print-Friendly View** - Clean two-column print layout optimized for paper
- **Mobile Responsive** - Works great on phones and tablets

## User Stories

- As a home cook, I want to save recipes from websites so I can access them without ads and popups
- As a user, I want to photograph a recipe from a cookbook so I can digitize my collection
- As a cook, I want to adjust serving sizes so ingredient quantities scale automatically
- As a user, I want to add personal notes to recipes so I remember my modifications
- As a user, I want to search my recipes so I can quickly find what I want to cook
- As a user, I want to print recipes so I can use them in the kitchen without a device

## Tech Stack

- **Ruby** 3.3.0
- **Rails** 8.x with Hotwire (Turbo + Stimulus)
- **Database** PostgreSQL
- **CSS** Tailwind CSS
- **File Storage** Active Storage
- **OCR** Tesseract
- **Asset Pipeline** Propshaft with Importmaps

## Prerequisites

- Ruby 3.3.0+
- PostgreSQL
- Tesseract OCR (for photo scanning)
- ImageMagick (for image processing)

### Installing Dependencies (macOS)

```bash
brew install postgresql tesseract imagemagick
```

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/justincadburywong/Epicer.git
   cd epicer
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Setup the database**
   ```bash
   bin/rails db:create db:migrate
   ```

4. **Start the server**
   ```bash
   bin/rails server
   ```

5. **Visit the app**
   Open [http://localhost:3000](http://localhost:3000)

### Accessing from Mobile (Local Network)

To access from your phone on the same WiFi network:

```bash
bin/rails server -b 0.0.0.0
```

Then visit `http://<your-computer-ip>:3000` on your phone.

> **Note:** Camera access for photo scanning requires HTTPS. Use a tunnel service like Cloudflare Tunnels or ngrok for camera functionality on mobile. File upload works without HTTPS.

## Running Tests

```bash
bin/rails test
```

## Project Structure

```
app/
├── controllers/
│   └── recipes_controller.rb    # CRUD, import, scan actions
├── models/
│   ├── recipe.rb                # Recipe with search scope
│   └── ingredient.rb            # Ingredients with scaling
├── services/
│   ├── recipe_scraper.rb        # URL scraping service
│   └── recipe_ocr.rb            # Tesseract OCR service
├── javascript/controllers/
│   ├── star_rating_controller.js
│   ├── servings_controller.js
│   ├── search_controller.js
│   └── camera_controller.js
└── views/recipes/
    ├── index.html.erb           # Recipe list with search
    ├── show.html.erb            # Recipe detail view
    ├── _form.html.erb           # Create/edit form
    ├── import.html.erb          # URL import page
    └── scan.html.erb            # Photo scan page
```

## Key Hotwire Patterns Used

- **Turbo Drive** - SPA-like page navigation without full reloads
- **Turbo Frames** - Partial page updates for search results
- **Stimulus Controllers** - Interactive star ratings, serving adjustment, camera capture

## License

MIT
