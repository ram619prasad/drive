class Folder < ApplicationRecord
  has_ancestry
  paginates_per 20
  has_many_attached :files

  # Associations
  belongs_to :user

  # Validations
  validates_uniqueness_of :name, scope: [:user_id, :ancestry]
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

  def update_file(file:, filename:)
    raise StandardError.new('Filename cannot be blank.') if filename.blank?
  
    # blob = ActiveStorage::Blob.find(id)
    old_filename = file.filename.to_s
    extension = ActiveStorage::Filename.new(old_filename).extension_with_delimiter

    # update the file's key and filename
    new_filename = filename + extension
    file.filename = new_filename
    file.key = ancestors.present? ?
                "#{user.email}/#{ancestors.map(&:name).join('/')}/#{name}/#{new_filename}" :
                "#{user.email}/#{name}/#{new_filename}"
    file.save!
    file
  end
end
