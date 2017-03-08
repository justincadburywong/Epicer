class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name_string
      t.email :email
      t.string :password_hash

      t.timestamps
    end
  end
end
