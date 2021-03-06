class User < ApplicationRecord
  has_secure_password

  # Validations
  validates_uniqueness_of :email
  validates_presence_of :first_name, :email
  validates :password, length: { minimum: 8 }, on: :create

  # Associations
  has_many :folders
  has_many :collaborations
  has_many :collaboration_folders, through: :collaborations, source: :folder

  # Instance Methods
  def upsert_bucket
    S3.put_object(bucket: "fidisys", key: "#{email}/")
  end

  # Class Methods
end
