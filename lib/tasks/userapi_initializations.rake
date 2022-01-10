namespace :userapi_initializations do
  task shipper_networks: :environment do
    Shipper.all.each do |shipper|
      shipper.user&.update_driver_network_id(shipper.network_id) if shipper.network_id
    end
  end
end
