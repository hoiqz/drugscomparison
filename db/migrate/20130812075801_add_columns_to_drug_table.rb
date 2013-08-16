class AddColumnsToDrugTable < ActiveRecord::Migration
  def change
    add_column :drugs, :prescription_for, :string
    add_column :drugs, :how_to_use, :string
    add_column :drugs, :other_uses, :string
    add_column :drugs, :dietary_precaution, :string
    add_column :drugs, :storage, :string
    add_column :drugs, :other_info, :string
    add_column :drugs, :other_known_names, :string
  end
end
