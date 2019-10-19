class UsersController < ApplicationController
  def sign_up
    user = User.new(user_params)
    if(user.save)
      render json: UserSerializer.new(user), status: :ok
    else
      render json: {errors: user.errors.messages}, status: :bad_request
    end
  end

  def sign_in
    email = user_params[:email]
    password = user_params[:password]
    user = User.find_by_email(email)
    if(!user)
      render json: {errors: {email: 'No user found with the given email.'}}, status: :bad_request
    elsif user && !user.authenticate(password)
      render json: {errors: {password: 'Wrong password. Please try again.'}}, status: :bad_request
    else
      render json: UserSerializer.new(user), status: :ok
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end
