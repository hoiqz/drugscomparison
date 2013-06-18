class Conditionmetric < ActiveRecord::Base
  attr_accessible :condition,:drug,:eff,:sat,:eou,:eff_bad,:eff_avg,:eff_good,:sat_bad,:sat_avg,:sat_good,:eou_bad,:eou_avg,:eou_good
end
