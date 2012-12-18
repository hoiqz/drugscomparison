class Drug < ActiveRecord::Base
  attr_accessible :brand_name, :dosage, :generic_name, :manufacturer, :precaution, :side_effect
end
