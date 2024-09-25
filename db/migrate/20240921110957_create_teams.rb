class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams, id: :uuid do |t|
      t.string :name, index: true
      t.string :owner_id, index: true
      t.integer :size

      t.timestamps
    end
  end
end
