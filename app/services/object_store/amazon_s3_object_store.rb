module ObjectStore
  class AmazonS3ObjectStore
    def initialize(bucket_name:, base_path:, region: 'us-east-1', credentials: default_credentials)
      @client = Aws::S3::Resource.new(region: region, credentials: credentials)
      @base_path = base_path
      @bucket_name = bucket_name
      @bucket = @client.bucket(bucket_name)
    end

    def upload_file(folder:, file_name:, file_local_path:)
      path = get_path(folder: folder, file_name: file_name)
      object = @bucket.object(path)
      object.upload_file(file_local_path)
    end

    private

    def put_params(s3_path:, path_to_file:)
      { body: path_to_file, bucket: @bucket_name, key: s3_path }
    end

    def get_path(folder:, file_name:)
      folder = folder[1..folder.length] if folder[0] == '/'
      folder = folder[0..folder.length - 1] if folder[folder.length - 1] == '/'
      file_name = file_name[1..file_name.length] if file_name[0] == '/'
      "#{@base_path}/#{folder}/#{file_name}"
    end

    def default_credentials
      Aws::Credentials.new(Rails.application.secrets.aws_access_key_id,
                           Rails.application.secrets.aws_secret_access_key)
    end
  end
end
