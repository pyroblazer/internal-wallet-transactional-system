class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.references :sender_wallet, null: false, foreign_key: { to_table: :wallets }, type: :uuid
      t.references :receiver_wallet, null: false, foreign_key: { to_table: :wallets }, type: :uuid
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :transaction_type, default: 0, null: false

      t.timestamps
    end
  end
end
