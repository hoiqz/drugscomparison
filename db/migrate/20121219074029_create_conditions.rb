class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.text :information

      t.timestamps
    end
  end
end
