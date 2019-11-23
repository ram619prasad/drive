class AddUniqIndexOnEmailsForUserModel < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :email, unique: true
    add_index :users, [:first_name, :last_name]
  end
end
