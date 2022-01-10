module PhotoPosition
  def save_photo_position(photo_params)
    photo_params.each do |photo|
      next if file(photo).nil?

      file(photo).update!(position: photo[:position]) unless photo[:position].nil?
    end
  end

  private

  def file(photo)
    return ActiveStorage::Attachment.find_by(blob_id: photo[:id]) if photo[:url].nil?

    ActiveStorage::Attachment.find_by(id: photo[:id])
  end
end
