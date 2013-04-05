class AddColumnToDrugTable < ActiveRecord::Migration
  def change
    add_column :drugs, :other_names, :string
    Drug.all.each do |drug|
      drug.update_attribute(:other_names,drug.brand_name)
    end
  end
end
