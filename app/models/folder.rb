class Folder < ApplicationRecord
  has_ancestry

  # Associations
  belongs_to :user
end
