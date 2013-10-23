class AddMoreColumnsToConditions < ActiveRecord::Migration
  def change
    add_column :conditions, :complications, :string
    add_column :conditions, :lifestyle, :string
    add_column :conditions, :coping_with_disease, :string
  end
end
