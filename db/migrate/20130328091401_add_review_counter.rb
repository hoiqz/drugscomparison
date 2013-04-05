class AddReviewCounter < ActiveRecord::Migration
  def up
    add_column :drugs, :reviews_count,:integer,:default=>0
    Drug.reset_column_information

  end

  def down
    remove_column :drugs, :reviews_count
  end
end
