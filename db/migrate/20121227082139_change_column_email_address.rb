class ChangeColumnEmailAddress < ActiveRecord::Migration
  def up
    change_column :users, :email_address, :string, :null => true
    add_index :treatments, :drug_id
    add_index :treatments, :condition_id
  end

  def down
    change_column :users, :email_address, :string, :null => false
    remove_index :treatments, :drug_id
    remove_index :treatments, :condition_id
  end
end
