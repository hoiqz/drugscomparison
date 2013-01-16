class Drug < ActiveRecord::Base
  attr_accessible :drug_id, :brand_name, :dosage, :generic_name, :manufacturer, :precaution, :side_effect,
                  :treatments_attributes, :reviews_attributes, :source_id, :conditions_attributes

  has_many :treatments ,
            #:foreign_key=>"condition_id",
           :dependent => :destroy
  has_many :conditions, :through => :treatments
  has_many :reviews

  accepts_nested_attributes_for :reviews, :allow_destroy => true, :reject_if => :reject_review
  accepts_nested_attributes_for :treatments, :allow_destroy => true, :reject_if => :reject_treatment
  accepts_nested_attributes_for :conditions


  validates :generic_name, :presence => true#, :uniqueness => true

  def reject_review(attributed)
    if attributed['comments'].blank? or attributed['effectiveness'].blank? or attributed['ease_of_use'].blank? or attributed['satisfactory'].blank?
      return true
    end
    return false
  end

  def reject_treatment(attributed)
    attributed['id'].blank?
  end





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

  def avg_eff
     score1=self.reviews.where("effectiveness=1").count
     score2=self.reviews.where("effectiveness=2").count
     score3=self.reviews.where("effectiveness=3").count
     score4=self.reviews.where("effectiveness=4").count
     score5=self.reviews.where("effectiveness=5").count
     sum=Float(self.reviews.count)
     weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
  def avg_eou
    score1=self.reviews.where("ease_of_use=1").count
    score2=self.reviews.where("ease_of_use=2").count
    score3=self.reviews.where("ease_of_use=3").count
    score4=self.reviews.where("ease_of_use=4").count
    score5=self.reviews.where("ease_of_use=5").count
    sum=Float(self.reviews.count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
  def avg_sat
    score1=self.reviews.where("satisfactory=1").count
    score2=self.reviews.where("satisfactory=2").count
    score3=self.reviews.where("satisfactory=3").count
    score4=self.reviews.where("satisfactory=4").count
    score5=self.reviews.where("satisfactory=5").count
    sum=Float(self.reviews.count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end

  def get_male_reviews

    @male=Array.new

    self.reviews.each do |review|
      userid=review.user_id
      if User.find(userid).gender =='Male'
        @male.push(review.id)
      end
    end
    return @male
  end

  def get_female_reviews
    @female=Array.new

    self.reviews.each do |review|
      userid=review.user_id
      if User.find(userid).gender =='Female'
        @female.push(review.id)
      end
    end
    return @female
  end
end
