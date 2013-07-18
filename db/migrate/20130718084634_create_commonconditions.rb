class CreateCommonconditions < ActiveRecord::Migration
  def change
    create_table :commonconditions do |t|
      t.string :name
      t.integer :condition_id
      t.string :category
      t.string :remarks

      t.timestamps
    end
  end
end
