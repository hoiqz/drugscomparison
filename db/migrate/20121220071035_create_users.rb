class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username  , :null => false
      t.integer :age , :null => false
      t.string :ethnicity
      t.string :email_address
      t.string :location
      t.string :gender , :null => false
      t.string :ip_address
      t.string :genome_file
      t.integer :weight
      t.string :smoking_status
      t.boolean :allow_contact  , :default=>true
      t.boolean :caregiver  , :default=>false

      t.timestamps
    end
  end
end
