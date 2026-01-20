class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.text :description
      t.text :instructions
      t.string :source_url
      t.integer :prep_time
      t.integer :cook_time
      t.integer :servings
      t.integer :rating
      t.text :notes

      t.timestamps
    end
  end
end
