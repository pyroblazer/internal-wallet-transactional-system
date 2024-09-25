class Transaction < ApplicationRecord
  belongs_to :sender_wallet, class_name: 'Wallet'
  belongs_to :receiver_wallet, class_name: 'Wallet'
  enum transaction_type: { debit: 0, credit: 1 }
end