class Createtables < ActiveRecord::Migration
  def change
    create_tables :users do |t|
      t.string :condition  
      t.string :drug
      t.float :eff
      t.float :sat
      t.float :eou
      t.integer :eff_bad
      t.integer :eff_avg
      t.integer :eff_good
      t.integer :sat_bad
      t.integer :sat_avg
      t.integer :sat_good
      t.integer :eou_bad
      t.integer :eou_avg
      t.integer :eou_good


      t.timestamps
    end
  end
end