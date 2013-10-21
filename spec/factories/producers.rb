# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :producer do
    sequence :id do |identificator|
      identificator
    end
    name Faker::Name.name
    rut "46741787-8"
    address Faker::Address.street_name
    phone Faker::PhoneNumber.phone_number
    contact_name Faker::Name.name
    contact_email Faker::Internet.email
    description Faker::Lorem.paragraphs([*2..6].sample)
    website Faker::Internet.url
    confirmed true
    corporate_name Faker::Name.name
    brief Faker::Lorem.paragraphs(1)
  end
end
