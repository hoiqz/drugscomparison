class Drug < ActiveRecord::Base
  attr_accessible :drug_id, :brand_name, :dosage, :generic_name, :manufacturer, :precaution, :side_effect,
                  :treatments_attributes, :reviews_attributes, :source_id, :conditions_attributes

  has_many :treatments ,
            #:foreign_key=>"condition_id",
           :dependent => :destroy
  has_many :conditions, :through => :treatments
  has_many :reviews
  #has_many :tags

  accepts_nested_attributes_for :reviews, :allow_destroy => true, :reject_if => :reject_review
  accepts_nested_attributes_for :treatments, :allow_destroy => true, :reject_if => :reject_treatment
  accepts_nested_attributes_for :conditions


  validates :brand_name, :presence => true#, :uniqueness => true

  def reject_review(attributed)
    if attributed['comments'].blank? or attributed['effectiveness'].blank? or attributed['ease_of_use'].blank? or attributed['satisfactory'].blank?
      return true
    end
    return false
  end

  def reject_treatment(attributed)
    attributed['id'].blank?
  end


  def get_all_reviews (options = {})
    #options[:for_drug_id]||options[:for_drug_id]=1
    query_record=Review.joins(:drug,:user).where(:drug_id=>options[:for_drug_id])  #always search with a drug id
                                                                                   # add in other search conditions depending on what options were passed in
    options.each do |key,value|
      if key=="gender"
        query_record=query_record.where(:users=>{:gender=>value})
        next
      end
      if key=="age"
        query_record=query_record.where(:users=>{:age=>value})
        next
      end
      if key =="location"
        query_record=query_record.where(:users=>{:location=>value})
        next
      end
      if key =="ethnicity"
        query_record=query_record.where(:users=>{:ethnicity=>value})
        next
      end
      if key =="weight"
        query_record=query_record.where(:users=>{:weight=>value})
        next
      end
      if key =="smoking_status"
        query_record=query_record.where(:users=>{:smoking_status=>value})
        next
      end
    end

    return query_record
  end

  def eff_score1(review)
    review.where("effectiveness=1").count
  end
  def eff_score2(review)
    review.where("effectiveness=2").count
  end
  def eff_score3(review)
    review.where("effectiveness=3").count
  end
  def eff_score4(review)
    review.where("effectiveness=4").count
  end
  def eff_score5(review)
    review.where("effectiveness=5").count
  end
  def eou_score1(review)
    review.where("ease_of_use=1").count
  end
  def eou_score2(review)
    review.where("ease_of_use=2").count
  end
  def eou_score3(review)
    review.where("ease_of_use=3").count
  end
  def eou_score4(review)
    review.where("ease_of_use=4").count
  end
  def eou_score5(review)
    review.where("ease_of_use=5").count
  end
  def sat_score1(review)
    review.where("satisfactory=1").count
  end
  def sat_score2(review)
    review.where("satisfactory=2").count
  end
  def sat_score3(review)
    review.where("satisfactory=3").count
  end
  def sat_score4(review)
    review.where("satisfactory=4").count
  end
  def sat_score5(review)
    review.where("satisfactory=5").count
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
