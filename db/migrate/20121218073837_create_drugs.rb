class CreateDrugs < ActiveRecord::Migration
  def change
    create_table :drugs do |t|
      t.string :generic_name
      t.string :brand_name
      t.string :side_effect
      t.text :dosage
      t.text :precaution
      t.string :manufacturer

      t.timestamps
    end
  end
end
