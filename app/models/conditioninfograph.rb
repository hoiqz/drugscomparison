class Conditioninfograph < ActiveRecord::Base
  attr_accessible :cheapest, :condition_id, :most_easy_to_use, :most_effective, :most_kids_using, :most_reviewed, :most_satisfied, :overall_winner, :top_side_effect, :total_reviews, :most_bad_reviews
  validates :condition_id, :uniqueness => true
end
