class Condition < ActiveRecord::Base
  attr_accessible :information
  has_many :treatments
  has_many :drugs, :through => :treatments
end
