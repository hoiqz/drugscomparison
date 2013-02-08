class AddColumnToConditioninfographs < ActiveRecord::Migration
  def self.up
    add_column :conditioninfographs, :most_bad_reviews, :string
  end
  def self.down
    remove_column :conditioninfographs, :most_bad_reviews
  end
end
