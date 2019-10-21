class FolderSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :name, :parent_id, :user_id, :parent_id, :children

  attribute :children do |object|
    object.children.select([:id, :name, :user_id])
  end
end
