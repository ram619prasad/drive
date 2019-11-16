class ApplicationController < ActionController::API
  before_action :authorize_user
  attr_reader :current_user

  private
  def authorize_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    payload = JsonWebToken.decode(header) || {}
    @current_user = User.find(payload[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: 'Could not find user. Invalid api_key.' }, status: 401
  rescue JWT::DecodeError => e
    render json: { errors: e.message }, status: :unauthorized
  end
end
