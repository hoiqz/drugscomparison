class Drug < ActiveRecord::Base
  attr_accessible :brand_name, :dosage, :generic_name, :manufacturer, :precaution, :side_effect
  has_many :treatments
  has_many :drugs, :through => :treatments
  validates :generic_name, :presence => true, :uniqueness => true
end
