class FoldersController < ApplicationController
  before_action :find_folder, only: [:show, :update, :destroy, :add_files, :remove_files, :rename_file, :move_files]
  before_action :find_files, only: [:rename_file]
  before_action :find_attachments, only: :move_files

  def create
    folder = current_user.folders.new(folder_params)

    if folder.save
      render json: FolderSerializer.new(folder), status: :created
    else
      render json: { errors: folder.errors.messages }, status: :bad_request
    end
  end

  def show
    render json: FolderSerializer.new(@folder), status: :ok
  rescue => e
    render json: { errors: e.message }, status: :not_found
  end

  def update
    @folder.update_attributes!(folder_params.except(:user_id))
    render json: FolderSerializer.new(@folder), status: :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  def destroy
    @folder.destroy
    head :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  def index
    folders = paginate current_user.folders, page: params[:page], per_page: params[:per_page]
    render json: FolderSerializer.new(folders), status: :ok
  end

  def add_files
    add_files_to_user_directory
    @folder.save!
    render json: FolderSerializer.new(@folder), status: :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  def remove_files
    @folder.files.purge
    render json: FolderSerializer.new(@folder), status: :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  def rename_file
    file = @folder.update_file(file: @file, filename: file_params[:filename])
    render json: { file: file }, status: :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  def move_files
    render json: { message: "No files are found with the ids #{folder_params[:files]}" }, status: :not_found and return if @attachments.blank?
    destination_folder = Folder.find(folder_params[:parent_id])

    # Move the files to the destination folder in S3
    Folder.move_files(@attachments, @folder, destination_folder, current_user)
    # Update Locally
    @attachments.update_all(record_id: destination_folder.id)
    render json: FolderSerializer.new(@folder.reload), status: :ok
  
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :user_id, :parent_id, files: [], file: [:id, :filename])
  end

  def file_params
    folder_params[:file]
  end

  def paginate_params
    params.permit(:page, :per_page)
  end

  def find_folder
    @folder = current_user.folders.with_attached_files.find(params[:id])
  rescue => e
    render json: { errors: e.message }, status: :not_found
  end

  def find_attachments
    @attachments = @folder.files.where(id: folder_params[:files])
  end

  def find_files
    @file = @folder.files.blobs.find(file_params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Could not find file with id: #{file_params[:id]} in folder #{@folder.name}(id: #{@folder.id})" }, status: :not_found
  end

  def add_files_to_user_directory
    return if folder_params[:files].blank?

    blobs = []
    folder_params[:files].each do |file|
      key = base_path_for_files_uploads(file)
      existing_blob = ActiveStorage::Blob.find_by(key: key)

      # Do not attach the duplicate files
      if existing_blob.blank?
        blob = ActiveStorage::Blob.new.tap do |blob|
          blob.filename = file.original_filename
          blob.key = key
          blob.upload file
          blob.save!
        end
        blobs << blob
      end
    end

    @folder.files.attach(blobs)
  rescue => e
    byebug
  end

  def base_path_for_files_uploads(file)
    config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
    path = @folder.ancestors.present? ?
             "#{current_user.email}/#{@folder.ancestors.map(&:name).join('/')}/#{@folder.name}/#{file.original_filename}" :
             "#{current_user.email}/#{@folder.name}/#{file.original_filename}"

    if Rails.configuration.active_storage.service.to_s == 'local'
      "storage/#{path}"
    elsif Rails.configuration.active_storage.service.to_s == 'amazon'
      path
    else
      "tmp/#{path}"
    end
  end
end
