# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    payment_status PTE::PaymentStatus.processing

    factory :completed_transaction do
      payment_status PTE::PaymentStatus.completed
    end

    factory :inactive_transaction do
      payment_status PTE::PaymentStatus.inactive
    end
  end
end
