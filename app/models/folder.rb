class Folder < ApplicationRecord
  has_ancestry
  paginates_per 20
  has_many_attached :files

  # Associations
  belongs_to :user
  has_many :collaborations
  has_many :collaborators, through: :collaborations, source: :user

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
        id: file.id, # This is attachment id but not the blob id
        filename: blob.filename.to_s,
        content_type: blob.content_type,
        byte_size: blob.byte_size,
        metadata: blob.metadata,
        created_at: blob.created_at,
        link: Rails.configuration.active_storage.service.to_s == 'amazon' ? file.blob.service_url : Rails.application.routes.url_helpers.rails_blob_url(file.blob)
      }
    end

    metadata
  end

  def update_file(file, filename, user)
    raise 'Filename cannot be blank.' if filename.blank?

    # blob = ActiveStorage::Blob.find(id)
    old_filename = file.filename.to_s
    extension = ActiveStorage::Filename.new(old_filename).extension_with_delimiter

    # Update the file's key and sync to S3
    new_filename = filename + extension
    return file if old_filename == new_filename

    # Need to check if we need to update all attachments/not?
    attachment = file.attachments.last

    source_key = Folder.base_path_for_files_uploads(attachment, self, user)
    # Need to update the local filename as well
    file.filename = new_filename

    target_key = Folder.base_path_for_files_uploads(attachment, self, user)
    file.key = target_key
    Folder.copy_object(source_key, target_key)
    Folder.delete_object(source_key)
    file.save!

    file
  end

  # Class Methods
  def self.move_files(files, source, destination, user)
    # The only way it works now is to 
    #       1. first copy the files to destination bucket
    #       2. delete the copied files from old folder.
    # Also we need to update the blob key so that there won't be confusion in the URL.
    files.each do |file|
      source_key = base_path_for_files_uploads(file, source, user)
      target_key = base_path_for_files_uploads(file, destination, user)

      blob = file.blob
      blob.key = target_key
      blob.save!

      copy_and_delete_old_object(source_key, target_key)
    end
  end

  private

  def self.copy_and_delete_old_object(source_key, target_key)
    if Rails.configuration.active_storage.service.to_s == 'amazon'
      begin
        copy_object(source_key, target_key)
        delete_object(source_key)
      rescue StandardError => e
      end
    end
  end

  def self.copy_object(source_key, target_key, source_bucket: 'fidisys', target_bucket: 'fidisys')
    S3.copy_object(bucket: target_bucket, copy_source: "#{source_bucket}/#{source_key}", key: target_key)
  rescue StandardError => ex
    puts 'Caught exception copying object ' + source_key + ' from bucket ' + source_bucket + ' to bucket ' + target_bucket + ' as ' + target_key + ':'
    puts ex.message
  end

  def self.delete_object(source_key, source_bucket: 'fidisys')
    S3.delete_object(bucket: source_bucket, key: source_key)
  rescue StandardError => ex
    puts 'Caught exception deleting object ' + source_key + ' from bucket ' + source_bucket
    puts ex.message
  end

  def self.base_path_for_files_uploads(file, source, user)
    file = file.blob
    config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
    path = source.ancestors.present? ?
             "#{user.email}/#{source.ancestors.map(&:name).join('/')}/#{source.name}/#{file.filename}" :
             "#{user.email}/#{source.name}/#{file.filename}"

    if Rails.configuration.active_storage.service.to_s == 'local'
      "storage/#{path}"
    elsif Rails.configuration.active_storage.service.to_s == 'amazon'
      path
    else
      "tmp/#{path}"
    end
  end

end
