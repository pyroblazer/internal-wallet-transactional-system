class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks, id: :uuid do |t|
      t.string :ticker_symbol
      t.decimal :price, precision: 10, scale: 2
      
      t.timestamps
    end
  end
end
