class AddDrugIdToMostcommondrugsTable < ActiveRecord::Migration
  def change
    add_column :mostcommondrugs, :drug_id, :integer
  end
end
