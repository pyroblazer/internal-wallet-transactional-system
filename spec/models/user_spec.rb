require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    # Create an existing user to test the uniqueness validation
    create(:user, email: 'existing@example.com')
  end

  it { should have_one(:entity) }
  it { should have_one(:wallet).through(:entity) }

  # Create an existing user before testing uniqueness validation
  it 'validates uniqueness of email' do
    user = build(:user, email: 'existing@example.com')
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('has already been taken')
  end

  it { should have_secure_password }
end
