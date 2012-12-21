class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :drug
      t.references :user
      t.references :condition
      t.text :comments  , :null => false
      t.string :review_url
      t.float :effectiveness , :null => false
      t.float :ease_of_use   , :null => false
      t.float :satisfactory , :null => false
      t.float :tolerability  , :default=>0
      t.string :tag_cloud_path
      t.integer :similar_experience, :default=>0
      t.integer :usage_duration_days

      t.timestamps
    end
  end
end