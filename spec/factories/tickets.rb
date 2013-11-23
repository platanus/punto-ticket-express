# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    sequence :id do |identificator| identificator end

    association :ticket_type, factory: :ticket_type
    association :transaction, factory: :transaction
    association :promotion, factory: :promotion
  end
end
