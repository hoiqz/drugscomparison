class AddColumnsToConditions < ActiveRecord::Migration
  def change
        add_column :conditions, :symptoms, :string
        add_column :conditions, :causes, :string
        add_column :conditions, :risk_factors, :string
        add_column :conditions, :treatment_and_medication, :string
        add_column :conditions, :prevention, :string
        add_column :conditions, :other_names, :string
        add_column :conditions, :alternative_medication, :string
  end
end
