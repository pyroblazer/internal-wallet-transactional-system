FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }

    after(:create) do |user|
      create(:entity, entity: user)
    end
  end
end
