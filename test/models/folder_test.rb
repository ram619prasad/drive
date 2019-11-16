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
  context '#attached_files_metadata' do
    setup do
      @user = FactoryBot.create(:user)
      @folder = FactoryBot.create(:folder, user: @user)
    end

    context 'when folder has no attached files' do
      should 'return empty array' do
        assert_empty @folder.attached_files_metadata
      end
    end

    should 'return the array of hashes of files metadata' do
      img = Rack::Test::UploadedFile.new(Rails.root.join('test', 'assets', 'sample.jpg'), 'image/jpeg')
      @folder.files.attach(img)

      file_metadata = @folder.attached_files_metadata[0]
      # Ensure that we have all the necessary attributes
      [:id, :filename, :content_type, :byte_size, :metadata, :created_at, :link].each do |attr|
        assert file_metadata.has_key?(attr), "#{attr} is not present in file_metadata"
      end

      assert_equal @folder.files.first.id, file_metadata[:id]
      blob = @folder.files.first.blob
      assert_equal blob.filename, file_metadata[:filename]
      assert_equal blob.content_type, file_metadata[:content_type]
      assert_equal blob.byte_size, file_metadata[:byte_size]
      assert_equal Rails.application.routes.url_helpers.rails_blob_url(blob), file_metadata[:link]
    end
  end

  context '#update_file' do
    setup do
      @folder = FactoryBot.create(:folder)
      img = Rack::Test::UploadedFile.new(Rails.root.join('test', 'assets', 'sample.jpg'), 'image/jpeg')
      @folder.files.attach(img)
      @attachment = @folder.files.first
      @blob = @attachment.blob
    end

    should 'rename the file as expected' do
      new_name = 'new_name'
      @folder.update_file(file: @blob, filename: new_name)
      assert_equal @blob.reload.filename.to_s, new_name + ActiveStorage::Filename.new(@blob.filename.to_s).extension_with_delimiter
    end

    should 'raise StandardError if no new filename is specified' do
      assert_raises_with_message(RuntimeError, 'Filename cannot be blank.') do
        @folder.update_file(file: @blob, filename: nil)
      end
    end
  end

  # Class Methods
end
