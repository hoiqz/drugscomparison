class Treatment < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :drug_id , :condition_id
  belongs_to :drug
  belongs_to :condition
  validates :drug_id, :presence => true
  validates :condition_id, :presence => true
end
