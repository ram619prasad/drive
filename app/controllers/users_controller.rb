class UsersController < ApplicationController
  skip_before_action :authorize_user, only: [:sign_up, :sign_in]

  def sign_up
    user = User.new(user_params)
    if user.save
      user.upsert_bucket
      api_token = JsonWebToken.encode({id: user.id}, browser: request.env['HTTP_USER_AGENT'])
      render json: { api_token: api_token }, status: :ok
    else
      render json: { errors: { messages: user.errors.messages } }, status: :bad_request
    end

  rescue Aws::S3::Errors::ServiceError
    render json: { error: { messages: I18n.t('user.signup_folder_create_error') } }, status: :interal_server_error
  rescue => e
    render json: { errors: { messages: e.message } }, status: :bad_request
  end

  def sign_in
    email = user_params[:email]
    password = user_params[:password]
    user = User.find_by_email(email)

    if(!user)
      render json: { errors: { messages: I18n.t('user.no_user_with_email') } }, status: :not_found
    elsif user && !user.authenticate(password)
      render json: { errors: { messages: I18n.t('user.invalid_password') } }, status: :bad_request
    else
      api_token = JsonWebToken.encode({ id: user.id }, browser: request.env['HTTP_USER_AGENT'])
      render json: { api_token: api_token }, status: :ok
    end
  end

  def profile
    render json: UserSerializer.new(current_user), status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end
