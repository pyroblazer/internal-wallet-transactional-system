FactoryBot.define do
  factory :stock do
    ticker_symbol { Faker::Finance.ticker }
    price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }

    after(:create) do |stock|
      create(:entity, entity: stock)
    end
  end
end
