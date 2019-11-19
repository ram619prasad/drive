class CollaborationsController < ApplicationController
  before_action :find_collaborator, only: [:create]
  before_action :find_folder, only: [:create]

  def create
    if current_user == @collaborator
      render json: { errors: { message: "You are alredy a collaborator." } }, status: :bad_request and return
    end

    Collaboration.create!(collab_params)
    render json: FolderSerializer.new(@folder), status: 201
  rescue => e
    render json: { errors: { message: e.message } }, status: :bad_request
  end

  def destroy
    user_id = collab_params[:user_id]
    folder_id = collab_params[:folder_id]
    collab = Collaboration.where(user_id: user_id, folder_id: folder_id).last
    render json: { errors: { message: "No collaboration found for the folder (id: #{folder_id}) with the user (id: #{user_id})" } }, status: :bad_request and return

    collab.destroy
    head :no_content 
  end

  private

  def find_collaborator
    @collaborator = User.find(collab_params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: { message: I18n.t('user.no_user_with_email') } }, status: :not_found and return
  end

  def find_folder
    folder_id = collab_params[:folder_id]
    @folder = current_user.folders.where(id: folder_id).last

    if @folder.blank?
      render json: { errors: { message: "No folder found with the given id #{folder_id}" } }, status: :not_found and return
    end
  end

  def collab_params
    params.require(:collaborations).permit(:user_id, :folder_id)
  end
end
