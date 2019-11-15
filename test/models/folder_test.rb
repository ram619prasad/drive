require 'test_helper'

class FolderTest < ActiveSupport::TestCase
  # DB Columns
  [:id, :name, :ancestry, :created_at, :updated_at].each do |col|
    should have_db_column(col)
  end

  # Validations
  [:user_id, :name].each do |col|
    should validate_presence_of(col)
  end

  context 'uniqueness and length validations' do
    setup { FactoryBot.create(:folder) }
    should validate_uniqueness_of(:name).scoped_to(:user_id, :ancestry)
  end

  should validate_length_of(:name)
           .is_at_least(3).with_short_message('name too short')
           .is_at_most(20).with_long_message('name too long')

  # Associations
  should belong_to :user

  # Instance Methods

  # Class Methods
end
