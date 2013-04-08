class AddReviewCounter < ActiveRecord::Migration
  def up
    add_column :drugs, :reviews_count,:integer,:default=>0


  end

  def down
    remove_column :drugs, :reviews_count
  end
end
