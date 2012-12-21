class AddConditionNameToConditions < ActiveRecord::Migration
  def self.up
    add_column :conditions, :name, :string
  end
  def self.down
    remove_column :conditions, :name
  end
end
