class AddSearchIndexesToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_index :recipes, :title
    add_index :recipes, :created_at
    add_index :recipes, :rating
  end
end
