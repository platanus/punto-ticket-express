# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    sequence :id do |identificator|
      identificator
    end
    name Faker::Name.name
    address Faker::Address.street_name
    description Faker::Lorem.paragraphs([*2..6].sample)
    custom_url Faker::Internet.url
    is_published false
    start_time Date.tomorrow
    end_time Date.tomorrow + 5.hours
    publish_start_time Date.tomorrow
    publish_end_time Date.tomorrow + 5.hours

    association :user, factory: :user
    association :producer, factory: :producer
  end
end
