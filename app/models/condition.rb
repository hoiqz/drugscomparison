class Condition < ActiveRecord::Base
  attr_accessible :information, :condition_id , :name
  has_many :treatments,
          # :foreign_key => "drug_id",
           :dependent => :destroy

  has_many :drugs, :through => :treatments
           #:source => "drug_id",
          # :dependent => :destroy




  def get_related_drugs
    druglist=self.drugs
    appended_drug=""
    druglist.each do |drug|
      #appended_drug.join(",#{drug.generic_name}")
      appended_drug<<",#{drug.generic_name}"
      appended_drug=appended_drug.sub(/^,/,"")
    end
    return appended_drug
  end
end
