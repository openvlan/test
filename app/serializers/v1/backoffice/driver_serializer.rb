module V1
  module Backoffice
    class DriverSerializer < ActiveModel::Serializer
      attributes :id, :status, :email, :first_name, :last_name, :birth_date, :phone_num,
                 :license_attributes, :working_hours, :vehicle_attributes, :company_attributes,
                 :provided_services, :code

      def email
        object.email
      end

      def code
        object.code
      end

      def status
        object.status.humanize
      end

      def license_attributes
        return nil unless object.license

        ActiveModelSerializers::SerializableResource.new(object.license,
                                                         serializer: V1::LicenseSerializer).as_json[:license]
      end

      def vehicle_attributes
        return nil unless object.vehicle

        ActiveModelSerializers::SerializableResource.new(object.vehicle,
                                                         serializer: V1::VehicleSerializer).as_json[:vehicle]
      end

      def company_attributes
        return nil unless object.company

        ActiveModelSerializers::SerializableResource.new(
          object.company,
          serializer: V1::CompanySerializer
        ).as_json[:company].merge(
          address_attributes: ActiveModelSerializers::SerializableResource.new(
            object.company.address,
            serializer: V1::AddressSerializer
          ).as_json[:address]
        )
      end
    end
  end
end
