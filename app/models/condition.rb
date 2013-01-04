class Condition < ActiveRecord::Base
  attr_accessible :information, :condition_id , :name
  has_many :treatments,
          # :foreign_key => "drug_id",
           :dependent => :destroy

  has_many :drugs, :through => :treatments
           #:source => "drug_id",
          # :dependent => :destroy

   validates :name,:uniqueness => true


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

  def get_male_reviews (for_drug_id)
    #@male=Array.new
    Review.joins(:drug,:user).where(:users=>{:gender=>'Male'},:drug_id=>for_drug_id)

  end
  def get_male_reviews_counts (for_drug_id)
    #@male=Array.new
    Review.joins(:drug,:user).where(:users=>{:gender=>'Male'},:drug_id=>for_drug_id).counts
  end

  def get_female_reviews (for_drug_id)
    #@male=Array.new
    Review.joins(:drug,:user).where(:users=>{:gender=>'Female'},:drug_id=>for_drug_id)
  end
  def get_female_reviews_counts (for_drug_id)
    #@male=Array.new
    Review.joins(:drug,:user).where(:users=>{:gender=>'Female'},:drug_id=>for_drug_id).counts
  end
end
