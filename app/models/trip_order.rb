class TripOrder < ApplicationRecord
  belongs_to :trip
  belongs_to :order
end
