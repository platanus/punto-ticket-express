# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promotion_code do
    code Faker::Lorem.characters(8)
    group_number 1

    association :user, factory: :user
    association :promotion, factory: :promotion
  end
end
