class ApplicationController < ActionController::API
  before_action :authorize_user
  attr_reader :current_user

  private

  def authorize_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    payload = JsonWebToken.decode(header) || {}
    @current_user = User.find(payload[:id])
  rescue JWT::DecodeError => e
    render json: { message: e.message }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound => e
    render json: { message: "You are not authorized to perform this action." }, status: 401
  end
end
