class User < ApplicationRecord
    has_secure_password

    # Validations
    validates_uniqueness_of :email
    validates_presence_of :first_name, :email
    validates :password, length: { minimum: 8 }, on: :create

    # Associations
end
