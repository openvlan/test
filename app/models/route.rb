class Route < ApplicationRecord
  validates :path, presence: true
  validates :path, uniqueness: { scope: :role }
end
