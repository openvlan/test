class Network < UserApiResource
  def self.closest(point)
    network_as_hash = get(:closest, gps_coordinates: point)
    Network.new(network_as_hash) if network_as_hash.present?
  end
end
