require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'associations' do
    it { should have_one(:entity).dependent(:destroy) }
  end

  describe 'creating a team with an entity and wallet' do
    it 'creates a team with a wallet and associated entity' do
      team = create(:team)
      entity = team.entity
      wallet = create(:wallet, walletable: team)

      expect(entity).to be_present
      expect(wallet).to be_present
      expect(wallet.walletable).to eq(team)
    end
  end
end
