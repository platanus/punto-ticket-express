# -*- coding: utf-8 -*-
require 'spec_helper'

describe Transaction do
  general_error = I18n.t("activerecord.errors.models.transaction.unknown_error")

  describe "#begin" do
    let(:user) { create(:user) }

    it "fails if inexistent user given" do
      t = Transaction.begin(2, nil, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid user given")
    end

    it "fails if not ticket types given" do
      t = Transaction.begin(user.id, nil, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid ticket types array")
    end

    it "fails if ticket types collection it is not Array" do
      types = {}
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid ticket types array")
    end

    it "fails if ticket types are not present on db" do
      ticket_type = build(:ticket_type, id: nil, bought_quantity: 2)
      t = Transaction.begin(user.id, [ticket_type], nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Inexistent ticket type")
    end

    it "fails if any ticket type has invalid structure" do
      create(:ticket_type, id: 1, bought_quantity: 2)
      types = [{id: 1, bought_quantity: 2}]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("This is not a ticket type object")
    end

    it "fails if tickets types belong to different events" do
      event = create(:event, id: 1)
      event_two = create(:event, id: 2)
      type_one = create(:ticket_type, id: 2, quantity: 10, event: event, bought_quantity: 2)
      type_two = create(:ticket_type, id: 3, quantity: 2, event: event_two, bought_quantity: 2)
      types = [type_one, type_two]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Ticket types form multiple events found")
    end

    it "fails if no tickets left for given ticket type" do
      type = create(:ticket_type, id: 2, quantity: 2, bought_quantity: 3)
      t = Transaction.begin(user.id, [type], nil)
      t.errors.messages[:base].should include(
        I18n.t("activerecord.errors.models.transaction.not_available_tickets",
          ticket_type_name: type.name))
    end

    it "fails if nested resource param has invalid structure" do
      type = create(:ticket_type, id: 2, quantity: 4, bought_quantity: 2)
      invalid_nested_resource = ["attr1", "attr2"]
      data = {transaction_nested_resource: invalid_nested_resource}
      t = Transaction.begin(user.id, [type], data)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid nested_resource_data structure given")
    end

    it "fails if nested resource has valid structure and invalid attr names" do
      type = create(:ticket_type, id: 2, quantity: 4, bought_quantity: 2)
      invalid_nested_resource = {invalid_attr_name: 'value1'}
      data = {transaction_nested_resource: invalid_nested_resource}
      t = Transaction.begin(user.id, [type], data)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid nested_resource_data structure given")
    end

    it "fails if options[:promotions] has invalid structure" do
      type = create(:ticket_type, id: 2, quantity: 4, bought_quantity: 2)
      invalid_promotions_param = [{ticket_type_id: 1, promotion: nil}]
      data = promotions = {promotions: invalid_promotions_param}
      t = Transaction.begin(user.id, [type], data)
      expect(t.error).to eq("Problem applying promotions")
    end

    it "creates transaction for given ticket types" do
      event = create(:event, id: 1)
      type_one = create(:ticket_type, id: 2, quantity: 10, event: event, bought_quantity: 5)
      type_two = create(:ticket_type, id: 3, quantity: 10, event: event, bought_quantity: 4)
      t = Transaction.begin(user.id, [type_one, type_two], nil)
      expect(t.ticket_types.size).to eq(2)
      expect(t.payment_status).to eq(PTE::PaymentStatus.processing)
      expect(t.event.id).to eq(event.id)
      expect(t.user.id).to eq(user.id)
      expect(t.ticket_types.first.tickets.size).to eq(5)
      expect(t.ticket_types.last.tickets.size).to eq(4)
      expect(type_one.available_tickets_count).to eq(5)
      expect(type_two.available_tickets_count).to eq(6)
    end

    it "creates transaction with given promotions" do
      event = create(:event)

      type_one = create(:ticket_type, id: 2, quantity: 10, event: event, bought_quantity: 2, price: 1000)
      type_two = create(:ticket_type, id: 3, quantity: 10, event: event, bought_quantity: 2, price: 500)
      type_three = create(:ticket_type, id: 4, quantity: 10, event: event, bought_quantity: 3, price: 200)
      type_four = create(:ticket_type, id: 5, quantity: 10, event: event, bought_quantity: 1, price: 1000)

      promo_one = create(:percent_promotion, promotion_type_config: 20, promotable: type_one, activation_code: nil)
      promo_two = create(:amount_promotion, promotion_type_config: 200, promotable: type_two, activation_code: nil)
      promo_three = create(:nx1_promotion, promotion_type_config: 2, promotable: type_three, activation_code: nil)
      promo_four = create(:percent_promotion, promotion_type_config: 60, promotable: type_four,
          activation_code: "LEANSCODE", validation_code: "LEANSCODE")

      promotions = [
        {ticket_type_id: 2, promotion: promo_one},
        {ticket_type_id: 3, promotion: promo_two},
        {ticket_type_id: 4, promotion: promo_three},
        {ticket_type_id: 5, promotion: promo_four}]
      data = {promotions: promotions}

      t = Transaction.begin(user.id, [type_one, type_two, type_three, type_four], data)
      expect(t.total_amount.to_i).to eq(3000) #price with all discounts applied
      expect(t.ticket_types.first.tickets.first.promotion.id).to eq(promo_one.id)
      expect(t.ticket_types.first.tickets.last.promotion.id).to eq(promo_one.id)
      expect(t.ticket_types[1].tickets.first.promotion.id).to eq(promo_two.id)
      expect(t.ticket_types[1].tickets.last.promotion.id).to eq(promo_two.id)
      expect(t.ticket_types[2].tickets.first.promotion.id).to eq(promo_three.id)
      expect(t.ticket_types[2].tickets[1].promotion.id).to eq(promo_three.id)
      expect(t.ticket_types[2].tickets.last.promotion).to be_nil
      expect(t.ticket_types.last.tickets.first.promotion.id).to eq(promo_four.id)
    end

    it "creates transaction with valid nested resource" do
      event = create(:event, id: 1)
      event.data_to_collect = {"0"=>{"name"=>"last_name", "value"=>"required"}}
      event.save
      type = create(:ticket_type, id: 2, quantity: 10, event: event, bought_quantity: 5)
      valid_nested_resource = {last_name: 'Segovia', name: 'Leandro'}
      data = {transaction_nested_resource: valid_nested_resource}
      t = Transaction.begin(user.id, [type], data)
      expect(t.nested_resource).not_to be_nil
      expect(t.nested_resource.name).to eq('Leandro')
      expect(t.nested_resource.last_name).to eq('Segovia')
      expect(t.nested_resource.required_attributes.include?(:last_name)).to be_true
    end

    it "creates transaction with valid tickets_nested_resources" do
      event = create(:event, id: 1)
      event.data_to_collect = {
        "0"=>{"name"=>"name", "value"=>"required"},
        "1"=>{"name"=>"last_name", "value"=>"optional"},
      }
      event.save
      type_one = create(:ticket_type, id: 2, quantity: 10, event: event, bought_quantity: 2)
      type_two = create(:ticket_type, id: 3, quantity: 10, event: event, bought_quantity: 2)

      tickets_nested_resources = [
        {:ticket_type_id=>"2", :resources=>[
          {"name"=>"Name participant 1", "last_name"=>"Last Name participant 1"},
          {"name"=>"Name participant 2", "last_name"=>""}]},
        {:ticket_type_id=>"3", :resources=>[
          {"name"=>"Name participant 3", "last_name"=>"Last Name participant 3"},
          {"name"=>"Name participant 4", "last_name"=>""}]}]

      data = {tickets_nested_resources: tickets_nested_resources}
      t = Transaction.begin(user.id, [type_one, type_two], data)
      expect(t.ticket_types.first.tickets.first.nested_resource).not_to be_nil
      expect(t.ticket_types.first.tickets.last.nested_resource).not_to be_nil
    end
  end

  describe "#complete" do
    it "fails when no token given" do
      t = Transaction.complete(nil)
      expect(t).to be_nil
    end

    it "ends transaction successfully" do
      create(:transaction, token: "PROCCESSTOKEN")
      t = Transaction.complete("PROCCESSTOKEN")
      expect(t.with_irrecoverable_errors?).not_to be_true
      expect(t.payment_status).to eq(PTE::PaymentStatus.completed)
      expect(t.token).to eq("PROCCESSTOKEN")
      expect(t.error).to be_nil
    end
  end

  describe "#cancel" do
    it "fails when no token given" do
      t = Transaction.cancel(nil)
      expect(t.error).to eq('transaction not found using given token')
      t = Transaction.cancel('NO_THIS_TOKEN_IN_DATABASE')
      expect(t.error).to eq('transaction not found using given token')
    end

    it "ends transaction with invalid state with no error message" do
      create(:transaction, token: "PROCCESSTOKEN")
      t = Transaction.cancel('PROCCESSTOKEN', nil)
      expect(t.payment_status).to eq(PTE::PaymentStatus.inactive)
      expect(t.error).to be_nil
    end

    it "ends transaction with invalid state with error message" do
      create(:transaction, token: "PROCCESSTOKEN")
      t = Transaction.cancel('PROCCESSTOKEN', 'Some error')
      expect(t.payment_status).to eq(PTE::PaymentStatus.inactive)
      expect(t.error).to eq('Some error')
    end
  end
end
