module V1
  class TripStatusChangeAuditSerializer < ActiveModel::Serializer
    attributes  :id,
                :status,
                :event,
                :comments,
                :created_at
  end
end
