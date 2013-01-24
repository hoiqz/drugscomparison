class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :keyword
      t.string :gender
      t.string :age
      t.string :location
      t.string :ethnicity
      t.integer :weight
      t.string :smoking_status
      t.string :new
      t.string :show

      t.timestamps
    end
  end
end
