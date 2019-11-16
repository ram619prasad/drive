class FileSerializer
  include FastJsonapi::ObjectSerializer

  attributes :blob, :link

  attribute :link do |file|
    Rails.configuration.active_storage.service.to_s == 'amazon' ? file.blob.service_url : Rails.application.routes.url_helpers.rails_blob_url(file.blob)
  end
end
  