class CreateTreatments < ActiveRecord::Migration
  def change
    create_table :treatments do |t|

      t.timestamps
    end
  end
end
