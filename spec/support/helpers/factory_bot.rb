module FactoryBot
  module Syntax
    module Methods

      def steps_data(deliveries, pickup_schedule, dropoff_schedule)
        deliveries.each_with_object({ pickups: [],
                                      dropoffs: [] }) do |delivery,
          _steps|
          _steps[:pickups] << {
            delivery_id: [delivery.id],
            action: 'pickup',
            schedule: pickup_schedule,
            institution: delivery.giver,
            address: delivery.origin
          }
          _steps[:dropoffs] << {
            delivery_id: [delivery.id],
            action: 'dropoff',
            schedule: dropoff_schedule,
            institution: delivery.receiver,
            address: delivery.destination
          }
        end.values.flatten
      end

      def location_data(address)
        {
          place: place_name(address),
          address: {
            id: address.id,
            telephone: address.telephone,
            street_1: address.street_1,
            street_2: address.street_2,
            zip_code: address.zip_code,
            city: address.city,
            state: address.state,
            country: address.country
          },
          latlng: address.latlng,
          open_hours: address.open_hours,
          notes: address.notes,
          contact: contact_data(address)
        }
      end

      def place_name(address)
        address.institution ? address.institution.name : address.lookup
      end

      def contact_data(address)
        {
          name: address.contact_name,
          cellphone: address.contact_cellphone,
          email: address.contact_email
        }
      end

    end
  end
end
