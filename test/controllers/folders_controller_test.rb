require 'test_helper'

class FoldersControllerTest < ActionDispatch::IntegrationTest
  # extend Shoulda::Matchers::ActionController

  setup do
    @user = FactoryBot.create(:user)
    @api_token = sign_in(@user)
  end

  context 'create' do
    # should 'return 401' do
    #   post '/folders'
    #   unauthorized_route_assertions
    # end

    should 'create a folder and return response as expected' do
      post '/folders',
           params: { folder: {name: 'First Folder'} },
           headers: { Authorization: @api_token }
      assert_folder_response(json_response['data'])

      attributes = json_response['data']['attributes']
      assert_equal @user.id, attributes['user_id']
      assert_equal 'First Folder', attributes['name']
    end
  end

  private

  def assert_folder_response(response)
    %w(id type attributes).each do |attr|
      assert response.has_key?(attr), "#{attr} is not present in response"
    end

    attributes = response['attributes']
    %w(id name parent_id user_id children created_at updated_at).each do |attr|
      assert attributes.has_key?(attr), "#{attr} is not present in attributes hash"
    end
  end
end
