class RemoveConditionIdFromReview < ActiveRecord::Migration
  def up
    remove_column :reviews, :condition_id
  end

  def down
    add_column :reviews, :condition_id, :integer
  end
end
