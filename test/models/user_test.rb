require 'test_helper'

class UserTest < ActiveSupport::TestCase
  [:first_name, :last_name, :password_digest].each do |col|
    should have_db_column(col)
  end
end
