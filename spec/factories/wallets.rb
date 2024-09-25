FactoryBot.define do
  factory :wallet do
    balance { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    association :walletable, factory: :user

    after(:create) do |wallet|
      create(:entity, entity: wallet.walletable)
    end
  end
end
