# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :promotion do
    name "MyString"
    promotion_type "MyString"
    start_date "2013-10-22"
    end_date "2013-10-22"
    limit 1
    activation_code "MyString"
    promotion_type_config "MyString"
  end
end
