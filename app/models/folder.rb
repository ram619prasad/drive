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
        id: blob.id,
        filename: blob.filename.to_s,
        content_type: blob.content_type,
        byte_size: blob.byte_size,
        metadata: blob.metadata,
        link: Rails.configuration.active_storage.service.to_s == 'amazon' ? file.blob.service_url : Rails.application.routes.url_helpers.rails_blob_url(file.blob)
      }
    end

    metadata
  end
end
