class CreateAskapatients < ActiveRecord::Migration
  def change
    create_table :askapatients do |t|
      t.string :name
      t.string :source_id
      t.integer :current_reviews
      t.integer :latest_reviews

      t.timestamps
    end
  end
end
