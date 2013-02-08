class Druginfograph < ActiveRecord::Base
  attr_accessible :age_btw_18_50, :age_less_18, :age_more_50, :avg_sat_female, :avg_sat_male, :brand_name, :effective_less_3, :effective_over_3, :eou_over_3,:eou_less_3, :no_of_females, :no_of_males, :top_used_words
  validates :brand_name, :uniqueness => true
end
