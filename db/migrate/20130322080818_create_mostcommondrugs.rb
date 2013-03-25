class CreateMostcommondrugs < ActiveRecord::Migration
  def change
    create_table :mostcommondrugs do |t|
      t.string :brand_name
      t.integer :count

      t.timestamps
    end
  end
end
