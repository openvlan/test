class TripStepPhoto < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :shipper
  belongs_to :trip

  has_one_attached :file, dependent: :destroy
  validate :file_is_present

  def url
    return file.blob.service_url if Rails.application.secrets.storage_service == 'amazon'

    Rails.application.routes.url_helpers.rails_blob_url(file.blob, only_path: true)
  end

  private

  def file_is_present
    errors.add(:file, 'must be attached') unless file.attached?
  end
end
