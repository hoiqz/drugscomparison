class Treatment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :drug
  belongs_to :condition
end
