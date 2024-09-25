FactoryBot.define do
  factory :entity do
    association :entity, factory: :user
  end
end
