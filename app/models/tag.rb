class Tag < ActiveRecord::Base
  attr_accessible :brand_name, :word_list
  #belongs_to :drugs, :conditions
  validates :brand_name, :uniqueness => true

end
