class CreateNutritions < ActiveRecord::Migration[8.1]
  def change
    create_table :nutritions do |t|
      t.references :recipe, null: false, foreign_key: true
      t.float :calories
      t.float :carbohydrates
      t.float :cholesterol
      t.float :sodium
      t.float :fat
      t.float :protein

      t.timestamps
    end
  end
end
