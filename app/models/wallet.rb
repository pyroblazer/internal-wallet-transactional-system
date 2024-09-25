class Wallet < ApplicationRecord
  belongs_to :walletable, polymorphic: true
  has_many :transactions_as_sender, class_name: "Transaction", foreign_key: :sender_wallet_id
  has_many :transactions_as_receiver, class_name: "Transaction", foreign_key: :receiver_wallet_id

  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
