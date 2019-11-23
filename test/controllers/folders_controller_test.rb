require 'test_helper'

class FoldersControllerTest < ActionDispatch::IntegrationTest

  should route(:post, '/folders').to(controller: 'folders', action: 'create')
  should route(:get, '/folders/id').to(controller: 'folders', action: 'show', id: 'id')
  should route(:patch, '/folders/id').to(controller: 'folders', action: 'update', id: 'id')
  should route(:delete, '/folders/id').to(controller: 'folders', action: 'destroy', id: 'id')
  should route(:get, '/folders/id/list_files').to(controller: 'folders', action: 'list_files', id: 'id')
  should route(:post, '/folders/id/add_files').to(controller: 'folders', action: 'add_files', id: 'id')
  should route(:patch, '/folders/id/remove_files').to(controller: 'folders', action: 'remove_files', id: 'id')
  should route(:post, '/folders/id/move_files').to(controller: 'folders', action: 'move_files', id: 'id')
  should route(:patch, '/folders/id/rename_file').to(controller: 'folders', action: 'rename_file', id: 'id')

  setup do
    @user = FactoryBot.create(:user)
    @api_token = sign_in(@user)
  end

  context 'create' do
    should 'return 401' do
      post '/folders'
      unauthorized_route_assertions
    end

    should 'create a folder and return response as expected' do
      post '/folders',
           params: { folder: {name: 'First Folder'} },
           headers: { Authorization: @api_token }
      assert_folder_response(json_response['data'], name: 'First Folder', user: @user)
    end
  end

  context 'show' do
    setup do
      @folder = FactoryBot.create(:folder, user: @user)
    end

    should 'return 401' do
      get '/folders', params: {id: @folder.id}
      unauthorized_route_assertions
    end

    should 'return folder as expected' do
      get '/folders', params: {id: @folder.id}, headers: { Authorization: @api_token }
      assert_folder_response(json_response['data'][0], name: @folder.name, user: @user)
    end
  end

  context 'update' do
    setup do
      @folder = FactoryBot.create(:folder, user: @user)
    end

    should 'return 404 when invalid folder_id is passed' do
      patch "/folders/12345", headers: { Authorization: @api_token }
      assert_response :not_found
    end

    should 'return error when updating a folder with no name' do
      patch "/folders/#{@folder.id}",
        params: { folder: { name: nil } },
        headers: { Authorization: @api_token }

      assert_bad_request
      assert_equal "Validation failed: Name can't be blank, Name name too short", json_response['errors']['messages']
    end

    should 'update the folder name as expected' do
      patch "/folders/#{@folder.id}",
        params: { folder: { name: 'New Name' } },
        headers: { Authorization: @api_token }

      assert_response :ok
      assert_folder_response(json_response['data'], name: 'New Name', user: @user)
    end

    should 'not update the user_id even though provided in params' do
      patch "/folders/#{@folder.id}",
        params: { folder: { name: 'New Name', user_id: '123' } },
        headers: { Authorization: @api_token }

      assert_response :ok
      assert_folder_response(json_response['data'], name: 'New Name', user: @user)
    end
  end

  context 'destroy' do
    setup do
      @folder = FactoryBot.create(:folder, user: @user)
    end

    should 'destroy a folder' do
      assert_difference "Folder.count", -1 do
        delete "/folders/#{@folder.id}", headers: { Authorization: @api_token }        
      end
      assert_response :ok
    end
  end

  context 'folders with files' do
    setup do
      @folder = FactoryBot.create(:folder, user: @user)
      img = Rack::Test::UploadedFile.new(Rails.root.join('test', 'assets', 'sample.jpg'), 'image/jpeg')
      @folder.files.attach(img)
    end

    context 'list_files' do
      should 'return files as expected' do
        get "/folders/#{@folder.id}/list_files", headers: { Authorization: @api_token }
      end
    end
  end

  private

  def assert_folder_response(response, name: nil, user: nil)
    %w(id type attributes).each do |attr|
      assert response.has_key?(attr), "#{attr} is not present in response"
    end

    attributes = response['attributes']
    %w(id name parent_id user_id children created_at updated_at).each do |attr|
      assert attributes.has_key?(attr), "#{attr} is not present in attributes hash"
    end

    assert_equal user.id, attributes['user_id'] if user
    assert_equal name, attributes['name'] if name
  end
end
