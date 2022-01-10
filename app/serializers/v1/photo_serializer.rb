module V1
  class PhotoSerializer < ActiveModel::Serializer
    type :photo

    attributes  :id,
                :url,
                :position,
                :signed_id

    def url
      return object.blob.service_url if Rails.application.secrets.storage_service == 'amazon'

      Rails.application.routes.url_helpers.rails_blob_url(object.blob, only_path: true)
    end
  end
end
