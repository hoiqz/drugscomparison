class Askapatient < ActiveRecord::Base
  attr_accessible :current_reviews, :latest_reviews, :name, :source_id
end
