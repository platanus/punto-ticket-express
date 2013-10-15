# -*- coding: utf-8 -*-
require 'spec_helper'

describe Transaction do
  describe "#begin" do
    let(:user) { create(:user) }
    general_error = "Ocurrió un error desconocido y la transacción fue cancelada"
    let(:event) { create(:event, id: 1) }
    let(:event_two) { create(:event, id: 2) }
    let(:ticket_type_one) { create(:ticket_type, id: 1, event: event) }
    let(:ticket_type_two) { create(:ticket_type, id: 2, event: event) }
    let(:ticket_type_three) { create(:ticket_type, id: 3, event: event_two) }

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
      types = [{id: 7, qty: 5},{id: 8, qty: 4}]
      t = Transaction.begin(user.id, types, nil)
      t.errors.messages[:base].should include(general_error)
      expect(t.error).to eq("Inexistent ticket type")
    end

    it "fails if any ticket type has invalid structure" do
      types = [{id: 1, quantity: 2},{id: 2, q: 3}]
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
  end
end
