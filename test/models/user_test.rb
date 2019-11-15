require 'test_helper'

class UserTest < ActiveSupport::TestCase
  [:id, :first_name, :last_name, :password_digest, :created_at, :updated_at].each do |col|
    should have_db_column(col)
  end

  # Validations
  [:first_name, :email].each do |col|
    should validate_presence_of(col)
  end

  should validate_uniqueness_of(:email)
  should validate_length_of(:password).is_at_least(8).on(:create)

  # Associations
  should have_many :folders

  # Instance Methods
  context '#upsert_bucket' do
    setup do
      @user = FactoryBot.create(:user)
    end

    should 'invoke S3 put_object call with necessary params' do
      S3.expects(:put_object).with({bucket: "fidisys", key: "#{@user.email}/"})
      @user.upsert_bucket
    end
  end

  # Class Methods

end
