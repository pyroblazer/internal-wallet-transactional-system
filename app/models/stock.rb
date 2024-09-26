class Stock < ApplicationRecord
  has_one :entity, as: :entity
  has_one :wallet, through: :entity

  def amount_invested(investor_wallet, stock_wallet)
    Transaction.where(
      sender_wallet: investor_wallet,
      receiver_wallet: stock_wallet,
      transaction_type: :debit).sum(:amount)
  end
end
