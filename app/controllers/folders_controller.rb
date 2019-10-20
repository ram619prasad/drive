class FoldersController < ApplicationController
  def create
    folder = Folder.new(folder_params)

    if folder.save
      render json: FolderSerializer.new(folder), status: :ok
    else
      render json: { errors: folder.errors.messages }, status: :bad_request
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :user_id, :parent_id)
  end
end
