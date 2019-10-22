class FoldersController < ApplicationController
  before_action :find_folder, only: [:show, :update, :destroy]

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

  private

  def folder_params
    params.require(:folder).permit(:name, :user_id, :parent_id)
  end

  def paginate_params
    params.permit(:page, :per_page)
  end

  def find_folder
    @folder = Folder.find(params[:id])
  rescue => e
    render json: { errors: e.message }, status: :not_found
  end
end
