class Condition < ActiveRecord::Base
  attr_accessible :information, :condition_id , :name,
                  :symptoms,:causes,:risk_factors,:treatment_and_medication,
                  :prevention,:other_names,:alternative_medication,:complications,:lifestyle,
                  :coping_with_disease
  has_many :treatments,
          # :foreign_key => "drug_id",
           :dependent => :destroy

  has_many :drugs, :through => :treatments
           #:source => "drug_id",
          # :dependent => :destroy
  #has_many :tags

   validates :name,:uniqueness => true

  searchable do
    text :name, :boost => 2.0
    text :information
  end

  scope :by_letter,
        lambda { |letter|
          where("name LIKE ?","#{letter}%")
        }

  scope :by_non_letter, where("name LIKE ?","1").where("name LIKE ?","2").where("name LIKE ?","3").where("name LIKE ?","4").where("name LIKE ?","5").where("name LIKE ?","6").where("name LIKE ?","7").where("name LIKE ?","8").where("name LIKE ?","9").where("name LIKE ?","0")


  def get_related_drugs
    druglist=self.drugs
    appended_drug=""
    druglist.each do |drug|
      #appended_drug.join(",#{drug.generic_name}")

      appended_drug<<",#{drug.brand_name}" if appended_drug !~/#{drug.brand_name}/
      appended_drug=appended_drug.sub(/^,/,"")
    end
    return appended_drug
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

  def get_male_reviews (for_drug_id)
    #@male=Array.new
    Review.joins(:drug,:user).where(:users=>{:gender=>'Male'},:drug_id=>for_drug_id)

  end


  def get_female_reviews (for_drug_id)
    #@male=Array.new
    Review.joins(:drug,:user).where(:users=>{:gender=>'Female'},:drug_id=>for_drug_id)
  end



  def avg_eff2(review)
    score1=review.where("effectiveness=1").count
    score2=review.where("effectiveness=2").count
    score3=review.where("effectiveness=3").count
    score4=review.where("effectiveness=4").count
    score5=review.where("effectiveness=5").count
    sum=Float(review.count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
  def avg_eou2(review)
    score1=review.where("ease_of_use=1").count
    score2=review.where("ease_of_use=2").count
    score3=review.where("ease_of_use=3").count
    score4=review.where("ease_of_use=4").count
    score5=review.where("ease_of_use=5").count
    sum=Float(review.count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
  def avg_sat2(review)
    score1=review.where("satisfactory=1").count
    score2=review.where("satisfactory=2").count
    score3=review.where("satisfactory=3").count
    score4=review.where("satisfactory=4").count
    score5=review.where("satisfactory=5").count
    sum=Float(review.count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
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

  ###DEPRECEATED METHODS!!
  # avg_* methods are for "all" tabs
  def avg_eff(drugid)
    score1=self.get_all_reviews(:for_drug_id=>drugid).where("effectiveness=1").count
    score2=self.get_all_reviews(:for_drug_id=>drugid).where("effectiveness=2").count
    score3=self.get_all_reviews(:for_drug_id=>drugid).where("effectiveness=3").count
    score4=self.get_all_reviews(:for_drug_id=>drugid).where("effectiveness=4").count
    score5=self.get_all_reviews(:for_drug_id=>drugid).where("effectiveness=5").count
    sum=Float(self.get_all_reviews(:for_drug_id=>drugid).count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
  def avg_eou(drugid)
    score1=self.get_all_reviews(:for_drug_id=>drugid).where("ease_of_use=1").count
    score2=self.get_all_reviews(:for_drug_id=>drugid).where("ease_of_use=2").count
    score3=self.get_all_reviews(:for_drug_id=>drugid).where("ease_of_use=3").count
    score4=self.get_all_reviews(:for_drug_id=>drugid).where("ease_of_use=4").count
    score5=self.get_all_reviews(:for_drug_id=>drugid).where("ease_of_use=5").count
    sum=Float(self.get_all_reviews(:for_drug_id=>drugid).count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
  def avg_sat(drugid)
    score1=self.get_all_reviews(:for_drug_id=>drugid).where("satisfactory=1").count
    score2=self.get_all_reviews(:for_drug_id=>drugid).where("satisfactory=2").count
    score3=self.get_all_reviews(:for_drug_id=>drugid).where("satisfactory=3").count
    score4=self.get_all_reviews(:for_drug_id=>drugid).where("satisfactory=4").count
    score5=self.get_all_reviews(:for_drug_id=>drugid).where("satisfactory=5").count
    sum=Float(self.get_all_reviews(:for_drug_id=>drugid).count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end
end
