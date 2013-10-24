# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promotion do
    name Faker::Name.name
    start_date Date.today
    end_date Date.today + 5.days
    limit 500
    association :ticket_type, factory: :ticket_type
    promotion_type PTE::PromoType.percent_discount
    promotion_type_config [*10..50].sample

    factory :code_promotion do
      promotion_type PTE::PromoType.code
      activation_code "XXXXXX"
      promotion_type_config ::Faker::Number.number(3).to_i
    end

    factory :percent_promotion do
      #just use defaults
    end

    factory :amount_promotion do
      promotion_type PTE::PromoType.amount_discount
      promotion_type_config ::Faker::Number.number(3).to_i
    end

    factory :nx1_promotion do
      promotion_type PTE::PromoType.nx1
      promotion_type_config ::Faker::Number.digit.to_i
    end
  end
end
