class FoldersController < ApplicationController
  before_action :find_folder, only: [:show, :update, :destroy, :add_files]

  def create
    folder = Folder.new(folder_params)

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
  #   @folder.files.attach(params[:folder][:files])
    @folder.save!
    render json: FolderSerializer.new(@folder), status: :ok
  rescue => e
    render json: { errors: e.message }, status: :bad_request
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :user_id, :parent_id, files: [])
  end

  def paginate_params
    params.permit(:page, :per_page)
  end

  def find_folder
    @folder = Folder.with_attached_files.find(params[:id])
  rescue => e
    render json: { errors: e.message }, status: :not_found
  end

  def add_files_to_user_directory
    return if folder_params[:files].blank?

    blobs = []
    folder_params[:files].each do |file|
      filename = file.original_filename
      existing_blob = ActiveStorage::Blob.find_by(filename: filename)

      # Do not attach the duplicate files
      if existing_blob.blank?
        blob = ActiveStorage::Blob.new.tap do |blob|
          blob.filename = filename
          blob.key = base_path_for_files_uploads(file)
          blob.upload file
          blob.save!
        end

        blobs << blob
      end
    end

    @folder.files.attach(blobs)
  end

  def base_path_for_files_uploads(file)
    config = YAML.load_file(Rails.root.join('config', 'storage.yml'))
    if Rails.configuration.active_storage.service.to_s == 'local'
      "storage/#{current_user.email}/#{file.original_filename}"
    elsif Rails.configuration.active_storage.service.to_s == 'amazon'
      config['amazon']['bucket'] + '/' + current_user.email + file.original_filename
    else
    end
  end
end
