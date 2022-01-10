module PhotoDestroy
  def destroy_photos(photo_params)
    photo_params.each do |photo|
      next if photo[:_destroy].nil? || photo[:id].nil? || file(photo[:id]).nil?

      file(photo[:id]).purge if photo[:_destroy]
    end
  end

  private

  def file(id)
    ActiveStorage::Attachment.find_by(id: id)
  end
end
