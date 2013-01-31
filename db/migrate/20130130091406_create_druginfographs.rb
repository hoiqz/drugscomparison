class CreateDruginfographs < ActiveRecord::Migration
  def change
    create_table :druginfographs do |t|
      t.string :brand_name
      t.float :avg_sat_male
      t.float :avg_sat_female
      t.string :top_used_words
      t.float :age_more_50
      t.float :age_less_18
      t.float :age_btw_18_50
      t.float :no_of_males
      t.float :no_of_females
      t.float :effective_over_4
      t.float :effective_less_4
      t.float :eou_over_4

      t.timestamps
    end
  end
end
