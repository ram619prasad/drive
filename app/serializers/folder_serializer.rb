class FolderSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :parent_id, :user_id
end
