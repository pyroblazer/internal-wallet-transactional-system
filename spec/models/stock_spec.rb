require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'associations' do
    it { should have_one(:entity) }
  end

  describe '#amount_invested' do
    let!(:user) { create(:user) }
    let!(:stock) { create(:stock) }
    let!(:investor_wallet) { create(:wallet, walletable: user.entity) }
    let!(:stock_wallet) { create(:wallet, walletable: stock.entity) }

    before do
      Transaction.create!(
        sender_wallet: investor_wallet,
        receiver_wallet: stock_wallet,
        amount: 100.0,
        transaction_type: :debit
      )
      Transaction.create!(
        sender_wallet: investor_wallet,
        receiver_wallet: stock_wallet,
        amount: 200.0,
        transaction_type: :debit
      )
      Transaction.create!(
        sender_wallet: investor_wallet,
        receiver_wallet: stock_wallet,
        amount: 150.0,
        transaction_type: :credit
      )
    end

    it 'calculates the total amount invested by the investor wallet' do
      total_invested = stock.amount_invested(investor_wallet, stock_wallet)
      expect(total_invested).to eq(300.0)
    end

    it 'returns 0 when there are no debit transactions' do
      empty_stock = create(:stock)
      empty_wallet = create(:wallet, walletable: user.entity)

      total_invested = empty_stock.amount_invested(empty_wallet, stock_wallet)
      expect(total_invested).to eq(0.0)
    end
  end
end
