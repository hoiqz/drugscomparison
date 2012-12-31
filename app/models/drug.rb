class Drug < ActiveRecord::Base
  attr_accessible :drug_id, :brand_name, :dosage, :generic_name, :manufacturer, :precaution, :side_effect,
                  :treatments_attributes, :reviews_attributes, :source_id, :conditions_attributes

  has_many :treatments ,
            #:foreign_key=>"condition_id",
           :dependent => :destroy
  has_many :conditions, :through => :treatments
  has_many :reviews

  accepts_nested_attributes_for :reviews #, :allow_destroy => true, :reject_if => :reject_review
  accepts_nested_attributes_for :treatments, :allow_destroy => true, :reject_if => :reject_treatment
  accepts_nested_attributes_for :conditions


  def reject_review(attributed)
    if attributed['comments'].blank? or attributed['effectiveness'].blank? or attributed['ease_of_use'].blank? or attributed['satisfactory'].blank?
      return true
    end
    return false
  end

  def reject_treatment(attributed)
    attributed['id'].blank?
  end


  validates :generic_name, :presence => true#, :uniqueness => true



  #this method is not working dur to some mass assignment crap
  def treats! (condition)
    self.treatments.new!(:condition_id=>condition)
    self.save
  end

  def get_related_conditions
    conditionslist=self.conditions
    appended_condition=""
    conditionslist.each do |condition|
      appended_condition<<",#{condition.generic_name}"
      appended_drug=appended_drug.sub(/^,/,"")
    end
    return appended_drug
  end
end
