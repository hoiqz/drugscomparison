class ChangeDruginfographTable < ActiveRecord::Migration
  def self.up
    add_column :druginfographs, :eou_less_3, :float
    rename_column :druginfographs, :effective_over_4, :effective_over_3
    rename_column :druginfographs, :effective_less_4, :effective_less_3
    rename_column :druginfographs, :eou_over_4, :eou_over_3
  end
  def self.down
    remove_column :reviews, :eou_less_3
    rename_column :druginfographs, :effective_over_3, :effective_over_4
    rename_column :druginfographs, :effective_less_3, :effective_less_4
    rename_column :druginfographs, :eou_over_3, :eou_over_4
  end
end
