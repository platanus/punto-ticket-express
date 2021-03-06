# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promotion do
    name Faker::Name.name
    start_date Date.today - 4.days
    end_date Date.today + 4.days
    limit 500
    association :promotable, factory: :ticket_type
    promotion_type PTE::PromoType.percent_discount
    promotion_type_config [*10..50].sample
    activation_code nil
    enabled true

    factory :percent_promotion do
      #just use defaults
    end

    factory :amount_promotion do
      promotion_type PTE::PromoType.amount_discount
      promotion_type_config ::Faker::Number.number(3).to_i
    end

    factory :nx1_promotion do
      promotion_type PTE::PromoType.nx1
      promotion_type_config [*2..5].sample
    end

    factory :event_promotion do
      association :promotable, factory: :event

      factory :percent_event_promotion do
        #just use defaults
      end

      factory :amount_event_promotion do
        promotion_type PTE::PromoType.amount_discount
        promotion_type_config ::Faker::Number.number(3).to_i
      end

      factory :nx1_event_promotion do
        promotion_type PTE::PromoType.nx1
        promotion_type_config [*2..5].sample
      end
    end
  end
end
