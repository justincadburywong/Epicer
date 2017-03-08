class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :description
      t.string :source
      t.string :category
      t.string :prep_time
      t.string :servings
      t.string :cals_serving
      t.binary :attachments
      t.string :notes
      t.string :ingredient1
      t.string :ingredient2
      t.string :ingredient3
      t.string :ingredient4
      t.string :ingredient5
      t.string :ingredient6
      t.string :ingredient7
      t.string :ingredient8
      t.string :ingredient9
      t.string :ingredient10
      t.string :ingredient11
      t.string :ingredient12
      t.string :ingredient13
      t.string :ingredient14
      t.string :ingredient15
      t.string :ingredient16
      t.string :ingredient17
      t.string :ingredient18
      t.string :ingredient19
      t.string :ingredient20
      t.string :ingredient21
      t.string :ingredient22
      t.string :quantity1
      t.string :quantity2
      t.string :quantity3
      t.string :quantity4
      t.string :quantity5
      t.string :quantity6
      t.string :quantity7
      t.string :quantity8
      t.string :quantity9
      t.string :quantity10
      t.string :quantity11
      t.string :quantity12
      t.string :quantity13
      t.string :quantity14
      t.string :quantity15
      t.string :quantity16
      t.string :quantity17
      t.string :quantity18
      t.string :quantity19
      t.string :quantity20
      t.string :quantity21
      t.string :quantity22
      t.text :instruction1
      t.text :instruction2
      t.text :instruction3
      t.text :instruction4
      t.text :instruction5
      t.text :instruction6
      t.text :instruction7
      t.text :instruction8
      t.text :instruction9
      t.text :instruction10
      t.text :instruction11
      t.text :instruction12
      t.text :instruction13
      t.text :instruction14
      t.text :instruction15
      t.text :instruction16
      t.text :instruction17
      t.text :instruction18
      t.text :instruction19
      t.text :instruction20

      # t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
