require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'associations' do
    it { should belong_to(:owner).class_name('User').required }
    it { should have_one(:entity) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:size) }
  end

  describe 'creating a team with an entity and wallet' do
    it 'creates a team with a wallet and associated entity' do
      team = create(:team)
      entity = team.entity
      wallet = create(:wallet, walletable: team.entity)

      expect(entity).to be_present
      expect(wallet).to be_present
      expect(wallet.walletable).to eq(team.entity)
    end
  end

  describe 'when creating a team without required attributes' do
    it 'is invalid without a name' do
      team = build(:team, name: nil)
      expect(team).to be_invalid
      expect(team.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a size' do
      team = build(:team, size: nil)
      expect(team).to be_invalid
      expect(team.errors[:size]).to include("can't be blank")
    end
  end
end
