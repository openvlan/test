# lib/active_storage/service/better_s3_service.rb
require 'aws-sdk-s3'
require 'active_storage/service/s3_service'
require 'active_support/core_ext/numeric/bytes'

module ActiveStorage
  class Service::BetterS3Service < Service::S3Service
    attr_reader :client, :bucket, :root, :upload_options

    def initialize(bucket:, upload: {}, **options)
      @root = options.delete(:root)
      super(bucket: bucket, upload: upload, **options)
    end

    private

    def object_for(key)
      path = root.present? ? File.join(root, key) : key
      bucket.object(path)
    end
  end
end
