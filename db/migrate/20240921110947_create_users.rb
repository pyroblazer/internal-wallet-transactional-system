class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email, null: false
      t.string :password_digest

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
