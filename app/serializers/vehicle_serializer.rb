class VehicleSerializer < Simple::VehicleSerializer
  belongs_to :shipper, serializer: Simple::ShipperSerializer
end
