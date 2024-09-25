FactoryBot.define do
  factory :transaction do
    association :sender_wallet, factory: :wallet
    association :receiver_wallet, factory: :wallet
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    transaction_type { :debit } # or :credit, can be overridden
  end
end
