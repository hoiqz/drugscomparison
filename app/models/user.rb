class User < ActiveRecord::Base
  attr_accessible :age, :allow_contact, :caregiver, :email_address, :ethnicity, :gender, :genome_file, :ip_address, :location, :smoking_status, :username, :weight,:reviews_attributes
  has_many :reviews,:dependent => :destroy
  accepts_nested_attributes_for :reviews, :allow_destroy => true




  validates :age, :numericality => true
  validates :email_address, :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i} ,:presence => true
  validates :gender, :presence => true
  validates :weight, :numericality => true

end
