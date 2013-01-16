class User < ActiveRecord::Base
  before_save :check_email

  before_destroy :delete_reviews

  attr_accessible :age, :allow_contact, :caregiver, :email_address, :ethnicity, :gender, :genome_file, :ip_address, :location, :smoking_status, :username, :weight,:reviews_attributes
  has_many :reviews , :dependent => :destroy ,:inverse_of => :user
  accepts_nested_attributes_for :reviews, :allow_destroy => true


 validates :username, :uniqueness => true
  #validates :age, :numericality => true
 # validates :email_address, :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i} #,:presence => true
  validates :gender, :presence => true
  #validates :weight, :numericality => true

  def check_email
    self.email_address=~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i if email_address
  end

  private
  def delete_reviews
      self.reviews.delete_all
  end
end
