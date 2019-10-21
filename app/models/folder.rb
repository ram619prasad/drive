class Folder < ApplicationRecord
  has_ancestry
  paginates_per 20

  # Associations
  belongs_to :user

  # Validations
  validates_presence_of :user_id, :name
  validates_length_of :name, within: 3..20, too_long: 'name too long', too_short: 'name too short'
end
