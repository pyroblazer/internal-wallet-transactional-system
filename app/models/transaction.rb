class Transaction < ApplicationRecord
  belongs_to :sender_wallet, class_name: "Wallet"
  belongs_to :receiver_wallet, class_name: "Wallet"
  enum :transaction_type, { debit: 0, credit: 1 }

  validates :amount, presence: true

  after_create :update_wallet_balances

  private
  def update_wallet_balances
    if debit?
      sender_wallet.update(balance: sender_wallet.balance - amount)
    elsif credit?
      receiver_wallet.update(balance: receiver_wallet.balance + amount)
    end
  end
end
