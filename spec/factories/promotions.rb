# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promotion do
    name Faker::Name.name
    promotion_type promotion_type PTE::PromoType.code
    start_date Date.today
    end_date Date.today + 5.days
    limit 500
    activation_code (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    promotion_type_config ::Faker::Number.number(3)

    factory :percent_promotion do
      promotion_type PTE::PromoType.percent_discount
      activation_code nil
      promotion_type_config [*10..50].sample.to_s
    end

    factory :amount_promotion do
      promotion_type PTE::PromoType.amount_discount
      activation_code nil
    end

    factory :nx1_promotion do
      promotion_type promotion_type PTE::PromoType.nx1
      activation_code nil
      promotion_type_config ::Faker::Number.digit
    end
  end
end
