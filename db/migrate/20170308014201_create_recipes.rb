class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :description
      t.string :source, :default => nil
      t.string :category
      t.string :prep_time, :default => nil
      t.string :servings, :default => nil
      t.string :cals_serving, :default => nil
      t.binary :attachments, :default => nil
      t.string :notes, :default => nil
      t.string :ingredient1
      t.string :ingredient2, :default => nil
      t.string :ingredient3, :default => nil
      t.string :ingredient4, :default => nil
      t.string :ingredient5, :default => nil
      t.string :ingredient6, :default => nil
      t.string :ingredient7, :default => nil
      t.string :ingredient8, :default => nil
      t.string :ingredient9, :default => nil
      t.string :ingredient10, :default => nil
      t.string :ingredient11, :default => nil
      t.string :ingredient12, :default => nil
      t.string :ingredient13, :default => nil
      t.string :ingredient14, :default => nil
      t.string :ingredient15, :default => nil
      t.string :ingredient16, :default => nil
      t.string :ingredient17, :default => nil
      t.string :ingredient18, :default => nil
      t.string :ingredient19, :default => nil
      t.string :ingredient20, :default => nil
      t.string :ingredient21, :default => nil
      t.string :ingredient22, :default => nil
      t.integer :quantity1
      t.integer :quantity2, :default => nil
      t.integer :quantity3, :default => nil
      t.integer :quantity4, :default => nil
      t.integer :quantity5, :default => nil
      t.integer :quantity6, :default => nil
      t.integer :quantity7, :default => nil
      t.integer :quantity8, :default => nil
      t.integer :quantity9, :default => nil
      t.integer :quantity10, :default => nil
      t.integer :quantity11, :default => nil
      t.integer :quantity12, :default => nil
      t.integer :quantity13, :default => nil
      t.integer :quantity14, :default => nil
      t.integer :quantity15, :default => nil
      t.integer :quantity16, :default => nil
      t.integer :quantity17, :default => nil
      t.integer :quantity18, :default => nil
      t.integer :quantity19, :default => nil
      t.integer :quantity20, :default => nil
      t.integer :quantity21, :default => nil
      t.integer :quantity22, :default => nil
      t.text :instruction1
      t.text :instruction2, :default => nil
      t.text :instruction3, :default => nil
      t.text :instruction4, :default => nil
      t.text :instruction5, :default => nil
      t.text :instruction6, :default => nil
      t.text :instruction7, :default => nil
      t.text :instruction8, :default => nil
      t.text :instruction9, :default => nil
      t.text :instruction10, :default => nil
      t.text :instruction11, :default => nil
      t.text :instruction12, :default => nil
      t.text :instruction13, :default => nil
      t.text :instruction14, :default => nil
      t.text :instruction15, :default => nil
      t.text :instruction16, :default => nil
      t.text :instruction17, :default => nil
      t.text :instruction18, :default => nil
      t.text :instruction19, :default => nil
      t.text :instruction20, :default => nil

      t.timestamps
    end
  end
end
