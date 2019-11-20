require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  should route(:post, '/users/sign_up').to(controller: :users, action: :sign_up)
  should route(:post, '/users/sign_in').to(controller: :users, action: :sign_in)
  should route(:get, '/users/profile').to(controller: :users, action: :profile)

  context 'sign_up' do
    setup do
      @params = {
        first_name: 'ram',
        last_name: 'prasad',
        email: 'ram.prasad@gmail.com',
        password: 'some strong password'
      }
    end

    should 'return error if email is not provided' do
      post '/users/sign_up', params: { user: @params.except(:email) }
      assert_response :bad_request
      assert json_response.has_key?('errors')
      assert json_response['errors']['messages'].has_key?('email')
      assert_equal ["can't be blank"], json_response['errors']['messages']['email']
    end

    should 'return error if first_name is not provided' do
      post '/users/sign_up', params: { user: @params.except(:first_name) }
      assert_response :bad_request
      assert json_response.has_key?('errors')
      assert json_response['errors']['messages'].has_key?('first_name')
      assert_equal ["can't be blank"], json_response['errors']['messages']['first_name']
    end

    should 'return error if password is not provided' do
      post '/users/sign_up', params: { user: @params.except(:password) }
      assert_response :bad_request
      assert json_response.has_key?('errors')
      assert json_response['errors']['messages'].has_key?('password')
      assert_equal ["can't be blank", "is too short (minimum is 8 characters)"], json_response['errors']['messages']['password']
    end

    should 'jwt token' do
      User.any_instance.expects(:upsert_bucket).once
      post '/users/sign_up', params: { user: @params }
      assert_response :ok
      assert json_response.has_key?('api_token')
      assert json_response['api_token'].length > 0
    end
  end

  context 'sing_in' do
    setup do
      @user = FactoryBot.create(:user)
    end

    should 'return error if no user if found with given email' do
      post '/users/sign_in', params: { user: { email: 'ram@gmail.com', password: @user.password } }
      assert_not_found
      assert_equal I18n.t('user.no_user_with_email'), json_response['errors']['messages']
    end

    should 'return error if wrong password is provided' do
      post '/users/sign_in', params: { user: { email: @user.email, password: 'invalid pwd' } }
      assert_bad_request
      assert_equal I18n.t('user.invalid_password'), json_response['errors']['messages']
    end

    should 'return api_token' do
      post '/users/sign_in', params: { user: { email: @user.email, password: @user.password } }
      assert_response :ok
      assert json_response.has_key?('api_token')
      assert json_response['api_token'].length > 0
    end
  end

  context 'profile' do
    setup do
      @user = FactoryBot.create(:user)
      @api_token = sign_in(@user)
    end

    should 'return the profile response as expected' do
      get '/users/profile', headers: {Authorization: @api_token}
      assert_response :ok

      data = json_response['data']
      %w(id type attributes).each do |attr|
        assert data.has_key?(attr), "#{attr} is not present in data hash"
      end

      attributes = data['attributes']
      %w(first_name last_name email).each do |attr|
        assert attributes.has_key?(attr), "#{attr} is not present in attributes hash"
      end
    end
    

    should 'return unauthoried when Authorization header is not provided' do
      get '/users/profile'
      unauthorized_route_assertions
    end
  end
end
