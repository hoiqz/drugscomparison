class AddReviewCounter < ActiveRecord::Migration
  def up
    add_column :drugs, :reviews_count,:integer,:default=>0
    Drug.reset_column_information
    Drug.all.each do |d|
      d.update_attribute :reviews_count, d.reviews.count
    end
  end

  def down
    remove_column :drugs, :reviews_count
  end
end
