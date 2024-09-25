class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets, id: :uuid do |t|
      t.references :walletable, polymorphic: true, null: false, type: :uuid
      t.decimal :balance, precision: 10, scale: 2, default: "0.0"
      
      t.timestamps
    end
  end
end
