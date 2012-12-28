class AddSourceidToDrug < ActiveRecord::Migration
  def self.up
    add_column :drugs, :source_id, :string
  end
  def self.down
    remove_column :drugs, :source_id
  end
end
