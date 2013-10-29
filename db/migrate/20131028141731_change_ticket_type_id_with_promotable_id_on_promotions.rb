class ChangeTicketTypeIdWithPromotableIdOnPromotions < ActiveRecord::Migration
  def up
    add_column :promotions, :promotable_id, :integer
    add_column :promotions, :promotable_type, :string
    remove_column :promotions, :ticket_type_id
  end

  def down
    remove_column :promotions, :promotable_id
    remove_column :promotions, :promotable_type
    add_column :promotions, :ticket_type_id, :integer
  end
end
