class FolderSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :parent_id, :user_id, :parent_id, :children, :created_at, :updated_at

  attribute :children do |object|
    object.children.select([:id, :name, :user_id])
  end
end
