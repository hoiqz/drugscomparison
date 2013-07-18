class CreateCommondrugs < ActiveRecord::Migration
  def change
    create_table :commondrugs do |t|
      t.string :brand_name
      t.integer :drug_id
      t.string :druglabels
      t.string :conditions
      t.timestamps
    end
  end

end
