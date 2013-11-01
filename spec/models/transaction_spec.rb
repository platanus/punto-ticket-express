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
      t = Transaction.begin(user.id, [type], invalid_nested_resource)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid nested_resource_data structure given")
    end

    it "fails if nested resource has valid structure and invalid attr names" do
      type = create(:ticket_type, id: 2, quantity: 4, bought_quantity: 2)
      invalid_nested_resource = {attrs: {invalid_attr_name: 'value1'}, required_attributes: [:invalid_attr_name]}
      t = Transaction.begin(user.id, [type], invalid_nested_resource)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid nested_resource_data structure given")
    end

    it "creates transaction for given ticket types and valid nested resource" do
      event = create(:event, id: 1)
      type_one = create(:ticket_type, id: 2, quantity: 10, event: event, bought_quantity: 5)
      type_two = create(:ticket_type, id: 3, quantity: 10, event: event, bought_quantity: 4)
      valid_nested_resource = {attrs: {last_name: 'Segovia', name: 'Leandro'}, required_attributes: [:last_name]}
      t = Transaction.begin(user.id, [type_one, type_two], valid_nested_resource)
      expect(t.ticket_types.size).to eq(2)
      expect(t.payment_status).to eq(PTE::PaymentStatus.processing)
      expect(t.event.id).to eq(event.id)
      expect(t.user.id).to eq(user.id)
      expect(t.ticket_types.first.tickets.size).to eq(5)
      expect(t.ticket_types.last.tickets.size).to eq(4)
      expect(type_one.available_tickets_count).to eq(5)
      expect(type_two.available_tickets_count).to eq(6)
      expect(t.nested_resource).not_to be_nil
      expect(t.nested_resource.name).to eq('Leandro')
      expect(t.nested_resource.last_name).to eq('Segovia')
      expect(t.nested_resource.required_attributes.include?(:last_name)).to be_true
    end
  end

  describe "#finish" do
    it "fails when no token given" do
      t = Transaction.finish(nil)
      expect(t.error).to eq("Invalid token given")
      expect(t.id).to be_nil
      t.errors.messages[:base].should include(general_error)
      expect(t.payment_status).to be_nil
      expect(t.with_errors?).to be_true
    end

    it "fails when non existent token given" do
      t = Transaction.finish("INEXISTENTTOKEN")
      expect(t.error).to eq("Transaction not found for given token")
      expect(t.id).to be_nil
      t.errors.messages[:base].should include(general_error)
      expect(t.payment_status).to be_nil
      expect(t.with_errors?).to be_true
    end

    it "fails when transaction was processed already" do
      create(:completed_transaction, token: "COMPLETEDTOKEN")
      t = Transaction.finish("COMPLETEDTOKEN")
      expect(t.error).to eq("Transaction with given token was processed already")
      expect(t.id).to be_nil
      expect(t.with_errors?).to be_true
      t.errors.messages[:base].should include(general_error)
      create(:inactive_transaction, token: "INACTIVETOKEN")
      t = Transaction.finish("INACTIVETOKEN")
      expect(t.error).to eq("Transaction with given token was processed already")
      expect(t.id).to be_nil
      expect(t.with_errors?).to be_true
      t.errors.messages[:base].should include(general_error)
    end

    it "ends transaction" do
      create(:transaction, token: "PROCCESSTOKEN")
      t = Transaction.finish("PROCCESSTOKEN")
      expect(t.with_errors?).not_to be_true
      expect(t.payment_status).to eq(PTE::PaymentStatus.completed)
      expect(t.token).to eq("PROCCESSTOKEN")
      expect(t.error).to be_nil
    end
  end
end
