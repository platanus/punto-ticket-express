# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence :id do |identificator|
      identificator
    end

    sequence :email do |n|
      "#{n}_#{Faker::Internet.email}"
    end

    role PTE::Role.user
    name Faker::Name.name
    password "12345678"
  end
end
