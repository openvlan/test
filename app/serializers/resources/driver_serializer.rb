module Resources
  class DriverSerializer < ActiveModel::Serializer
    attributes :id, :status, :email, :first_name, :last_name, :birth_date, :phone_num,
               :working_hours, :provided_services

    def email
      object.email
    end

    def status
      object.status.humanize
    end
  end
end
