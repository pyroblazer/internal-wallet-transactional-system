class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :sender_wallet_id, :receiver_wallet_id, :amount, :transaction_type
end
