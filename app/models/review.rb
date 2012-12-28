class Review < ActiveRecord::Base
  attr_accessible :comments, :drug_id, :ease_of_use, :effectiveness, :review_url, :satisfactory, :similar_experience, :tag_cloud_path, :tolerability, :usage_duration_days, :user_id, :user_attributes, :created_at
  belongs_to :drug
  #validates_presence_of :drug
  #belongs_to :condition

  belongs_to :user
  #accepts_nested_attributes_for :user

  validates :comments, :presence => true,
            :length => {:minimum => 5,:maximum => 2000}


  validates :ease_of_use, :numericality => true , :presence => true
  validates :effectiveness, :numericality => true , :presence => true
  validates :satisfactory, :numericality => true , :presence => true


  end

