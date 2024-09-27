FactoryBot.define do
  factory :team do
    name { Faker::Team.name }
    size { rand(1..10) }

    association :owner, factory: :user

    after(:create) do |team|
      create(:entity, entity: team)
    end
  end
end
