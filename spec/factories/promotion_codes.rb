# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promotion_code do
    code "MyString"
    user_id 1
  end
end
