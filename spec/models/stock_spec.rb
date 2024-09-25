require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'associations' do
    it { should have_one(:entity) }
    it { should have_one(:wallet).through(:entity) }
  end
end
