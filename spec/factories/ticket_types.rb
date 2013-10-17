# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket_type do
    sequence :id do |identificator| identificator end
    name ["Palco", "Vip", "Platea"].sample
    price [*5000..20000].sample
    quantity [*200..3000].sample

    association :event, factory: :event
  end
end
