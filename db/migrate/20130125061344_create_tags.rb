class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :brand_name
      t.string :word_list

      t.timestamps
    end
  end
end
