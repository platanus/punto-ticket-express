# -*- coding: utf-8 -*-
require 'spec_helper'

describe Transaction do
  general_error = I18n.t("activerecord.errors.models.transaction.unknown_error")

  describe "#begin" do
    let(:user) { create(:user) }
    let(:event) { create(:event, id: 1) }
    let(:event_two) { create(:event, id: 2) }
    let(:ticket_type_one) { create(:ticket_type, id: 1, quantity: 10, event: event) }
    let(:ticket_type_two) { create(:ticket_type, id: 2, quantity: 10, event: event) }
    let(:ticket_type_three) { create(:ticket_type, id: 3, quantity: 2, event: event_two) }

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
      types = {id: 1, qty: 3}
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid ticket types array")
    end

    it "fails if ticket types are not present on db" do
      types = [{id: 7, qty: 5}, {id: 8, qty: 4}]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Inexistent ticket type")
    end

    it "fails if any ticket type has invalid structure" do
      types = [{id: 1, quantity: 2}, {id: 2, q: 3}]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid ticket type format")
    end

    it "fails if tickets types belong to different events" do
      types = [{id: ticket_type_one.id, qty: 5},{id: ticket_type_three.id, qty: 4}]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Ticket types form multiple events found")
    end

    it "fails if no tickets left for given ticket type" do
      types = [{id: ticket_type_three.id, qty: 5}]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(
        I18n.t("activerecord.errors.models.transaction.not_available_tickets",
          ticket_type_name: ticket_type_three.name))
    end

    it "fails if nested resource param has invalid structure" do
      types = [{id: ticket_type_one.id, qty: 5}, {id: ticket_type_two.id, qty: 4}]
      invalid_nested_resource = ["attr1", "attr2"]
      t = Transaction.begin(user.id, types, invalid_nested_resource)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid nested_resource_data structure given")
    end

    it "fails if nested resource has valid structure and invalid attr names" do
      types = [{id: ticket_type_one.id, qty: 5}, {id: ticket_type_two.id, qty: 4}]
      invalid_nested_resource = {attrs: {invalid_attr_name: 'value1'}, required_attributes: [:invalid_attr_name]}
      t = Transaction.begin(user.id, types, invalid_nested_resource)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Invalid nested_resource_data structure given")
    end

    it "creates transaction for given ticket types and valid nested resource" do
      types = [{id: ticket_type_one.id, qty: 5}, {id: ticket_type_two.id, qty: 4}]
      valid_nested_resource = {attrs: {last_name: 'Segovia', name: 'Leandro'}, required_attributes: [:last_name]}
      t = Transaction.begin(user.id, types, valid_nested_resource)
      expect(t.ticket_types.size).to eq(2)
      expect(t.payment_status).to eq(PTE::PaymentStatus.processing)
      expect(t.event.id).to eq(event.id)
      expect(t.user.id).to eq(user.id)
      expect(t.ticket_types.first.tickets.size).to eq(5)
      expect(t.ticket_types.last.tickets.size).to eq(4)
      expect(ticket_type_one.available_tickets_count).to eq(5)
      expect(ticket_type_two.available_tickets_count).to eq(6)
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
