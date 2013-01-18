class AddColumnToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :other_drugs, :string
  end
  def self.down
    remove_column :reviews, :other_drugs
  end
end
