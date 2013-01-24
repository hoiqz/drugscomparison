class AddDrugNameColumnToSearch < ActiveRecord::Migration
  def self.up
    add_column :searches, :drug_name, :string
  end
  def self.down
    remove_column :searches, :drug_name
  end
end
