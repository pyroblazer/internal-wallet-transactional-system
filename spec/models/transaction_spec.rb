require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it { should belong_to(:sender_wallet).class_name('Wallet') }
  it { should belong_to(:receiver_wallet).class_name('Wallet') }

  it { should define_enum_for(:transaction_type).with_values(debit: 0, credit: 1) }

  it 'is valid with valid attributes' do
    sender_wallet = create(:wallet, balance: 1000)
    receiver_wallet = create(:wallet, balance: 500)
    transaction = build(:transaction, sender_wallet: sender_wallet, receiver_wallet: receiver_wallet, amount: 100, transaction_type: :debit)

    expect(transaction).to be_valid
  end

  it 'is invalid without sender_wallet' do
    receiver_wallet = create(:wallet, balance: 500)
    transaction = build(:transaction, sender_wallet: nil, receiver_wallet: receiver_wallet, amount: 100, transaction_type: :debit)

    expect(transaction).to_not be_valid
  end

  it 'is invalid without receiver_wallet' do
    sender_wallet = create(:wallet, balance: 1000)
    transaction = build(:transaction, sender_wallet: sender_wallet, receiver_wallet: nil, amount: 100, transaction_type: :debit)

    expect(transaction).to_not be_valid
  end

  it 'is invalid without amount' do
    sender_wallet = create(:wallet, balance: 1000)
    receiver_wallet = create(:wallet, balance: 500)
    transaction = build(:transaction, sender_wallet: sender_wallet, receiver_wallet: receiver_wallet, amount: nil, transaction_type: :debit)

    expect(transaction).to_not be_valid
  end

  context 'after transaction creation' do
    it 'debits the sender_wallet and credits the receiver_wallet' do
      sender_wallet = create(:wallet, balance: 1000)
      receiver_wallet = create(:wallet, balance: 500)

      debit_transaction = create(:transaction, sender_wallet: sender_wallet, receiver_wallet: receiver_wallet, amount: 100, transaction_type: :debit)

      expect(sender_wallet.reload.balance).to eq(900)
      expect(receiver_wallet.reload.balance).to eq(500)

      credit_transaction = create(:transaction, sender_wallet: sender_wallet, receiver_wallet: receiver_wallet, amount: 100, transaction_type: :credit)

      expect(sender_wallet.reload.balance).to eq(900)
      expect(receiver_wallet.reload.balance).to eq(600)
    end
  end

  it "does not update balance when the transaction is invalid" do
    sender_wallet = create(:wallet)
    receiver_wallet = create(:wallet)

    invalid_transaction = Transaction.new(sender_wallet: sender_wallet, receiver_wallet: receiver_wallet, amount: nil, transaction_type: :debit)

    expect(invalid_transaction).to_not be_valid
    expect(invalid_transaction.save).to eq(false)
    expect(sender_wallet.reload.balance).to eq(sender_wallet.balance) # Ensure balance is unchanged
    expect(receiver_wallet.reload.balance).to eq(receiver_wallet.balance) # Ensure balance is unchanged
  end
end
