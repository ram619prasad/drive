FactoryBot.define do
  factory :folder do
    user
    name { Faker::Lorem.characters(number: 10) }
  end
end
  