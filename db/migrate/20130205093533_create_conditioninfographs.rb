class CreateConditioninfographs < ActiveRecord::Migration
  def change
    create_table :conditioninfographs do |t|
      t.integer :condition_id
      t.string :most_reviewed
      t.float :cheapest
      t.string :most_satisfied
      t.string :most_kids_using
      t.float :total_reviews
      t.string :top_side_effect
      t.string :most_easy_to_use
      t.string :most_effective
      t.string :overall_winner

      t.timestamps
    end
  end
end
