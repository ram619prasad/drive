class Folder < ApplicationRecord
  has_ancestry
  paginates_per 20
  has_many_attached :files

  # Associations
  belongs_to :user
  # scope :with_eager_loaded_images, -> { preload(images_attachments: :blob) }

  # Validations
  validates_presence_of :user_id, :name
  validates_length_of :name, within: 3..20, too_long: 'name too long', too_short: 'name too short'

  # Instance Methods
  def attached_files_metadata
    metadata = []
    files.each do |file|
      blob = file.blob
      metadata << {
        filename: blob.filename.to_s,
        content_type: blob.content_type,
        byte_size: blob.byte_size,
        metadata: blob.metadata
      }
    end

    metadata
  end
end
