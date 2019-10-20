class UsersController < ApplicationController
  def sign_up
    user = User.new(user_params)
    user.upsert_bucket

    if(user.save)
      api_token = JsonWebToken.encode({id: user.id}, browser: request.env['HTTP_USER_AGENT'])
      render json: { api_token: api_token }, status: :ok
    else
      render json: { errors: user.errors.messages }, status: :bad_request
    end

  rescue
    render json: { error: { aws: 'Unable to create a folder for user in aws at the moment. Please try after sometime.' } }, status: :interal_server_error
  end

  def sign_in
    email = user_params[:email]
    password = user_params[:password]
    user = User.find_by_email(email)

    if(!user)
      render json: { errors: { email: 'No user found with the given email.' } }, status: :bad_request
    elsif user && !user.authenticate(password)
      render json: { errors: { password: 'Wrong password. Please try again.' } }, status: :bad_request
    else
      api_token = JsonWebToken.encode({ id: user.id }, browser: request.env['HTTP_USER_AGENT'])
      # render json: UserSerializer.new(user), status: :ok
      render json: { api_token: api_token }, status: :ok
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end
