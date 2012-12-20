class CreateTreatments < ActiveRecord::Migration
  def change
    create_table :treatments do |t|
      t.integer :drug_id
      t.integer :condition_id
      t.timestamps
    end
  end
end
