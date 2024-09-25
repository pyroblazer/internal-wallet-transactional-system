require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it { should belong_to(:sender_wallet).class_name('Wallet') }
  it { should belong_to(:receiver_wallet).class_name('Wallet') }

  it 'creates a valid transaction between wallets' do
    sender_wallet = create(:wallet)
    receiver_wallet = create(:wallet)
    transaction = create(:transaction, sender_wallet: sender_wallet, receiver_wallet: receiver_wallet)
    
    expect(transaction).to be_valid
    expect(transaction.sender_wallet).to eq(sender_wallet)
    expect(transaction.receiver_wallet).to eq(receiver_wallet)
  end
end

