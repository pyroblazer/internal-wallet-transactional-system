require 'rails_helper'

RSpec.describe Wallet, type: :model do
  it { should belong_to(:walletable) } # Polymorphic association

  it { should have_many(:transactions_as_sender).class_name('Transaction').with_foreign_key('sender_wallet_id') }
  it { should have_many(:transactions_as_receiver).class_name('Transaction').with_foreign_key('receiver_wallet_id') }

  it 'creates a wallet for a user' do
    wallet = create(:wallet)
    expect(wallet.walletable).to be_present
  end
end
