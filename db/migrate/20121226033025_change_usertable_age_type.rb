class ChangeUsertableAgeType < ActiveRecord::Migration
  def up
    change_column :users, :age, :string
  end

  def down
    change_column :users, :age, :integer
  end
end
