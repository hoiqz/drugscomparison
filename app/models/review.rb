class Review < ActiveRecord::Base
  attr_accessible :comments, :drug_id, :ease_of_use, :effectiveness, :review_url, :satisfactory, :similar_experience, :tag_cloud_path, :tolerability, :usage_duration_days, :user_attributes, :created_at, :other_drugs,:source
  belongs_to :drug, :inverse_of => :reviews , :counter_cache => true
  #validates_presence_of :drug
  #belongs_to :condition

  belongs_to :user, :inverse_of => :reviews
  accepts_nested_attributes_for :user

  validates :comments, :presence => true,
            :length => {:minimum => 5,:maximum => 2000}


  validates :ease_of_use , :presence => true
  validates :effectiveness, :presence => true
  validates :satisfactory , :presence => true

  searchable do
    text :comments
  end

end

