class Wallet < ApplicationRecord
  belongs_to :walletable, polymorphic: true
  has_many :transactions_as_sender, class_name: 'Transaction', foreign_key: :sender_wallet_id
  has_many :transactions_as_receiver, class_name: 'Transaction', foreign_key: :receiver_wallet_id
end
