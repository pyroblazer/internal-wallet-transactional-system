FactoryBot.define do
  factory :team do
    name { Faker::Team.name }
    team_lead { Faker::Name.name }
    team_size { rand(1..10) }

    after(:create) do |team|
      create(:entity, entity: team)
    end
  end
end
