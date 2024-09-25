class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams, id: :uuid do |t|
      t.string :name
      t.string :team_lead
      t.integer :team_size
      
      t.timestamps
    end
  end
end
