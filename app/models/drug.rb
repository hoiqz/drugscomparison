class Drug < ActiveRecord::Base
  attr_accessible :drug_id, :brand_name, :dosage, :generic_name, :manufacturer, :precaution, :side_effect
  has_many :treatments ,
            #:foreign_key=>"condition_id",
           :dependent => :destroy

  has_many :conditions, :through => :treatments
           #:dependent => :destroy

  validates :generic_name, :presence => true, :uniqueness => true

  #this method is not working dur to some mass assignment crap
  def treats! (condition)
    self.treatments.new!(:condition_id=>condition)
    self.save
  end
end
