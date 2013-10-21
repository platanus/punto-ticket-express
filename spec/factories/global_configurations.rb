# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :global_configuration do
    fixed_fee "9.99"
    percent_fee "9.99"
  end
end
