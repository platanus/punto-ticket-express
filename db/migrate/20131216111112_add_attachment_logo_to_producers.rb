class AddAttachmentLogoToProducers < ActiveRecord::Migration
  def self.up
    change_table :producers do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :producers, :logo
  end
end
