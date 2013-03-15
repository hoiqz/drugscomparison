class CreateWebmds < ActiveRecord::Migration
  def change
    create_table :webmds do |t|
      t.string :brand_name
      t.string :source_id
      t.integer :current_reviews
      t.integer :latest_reviews

      t.timestamps
    end
  end
end
