class Treatment < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :drug_id , :conditions_attributes
  belongs_to :drug
  belongs_to :condition
  accepts_nested_attributes_for :condition

  validates :drug_id, :presence => true
  validates :condition_id, :presence => true
end
