class TripEnoughTime
  def self.enough?(datetime)
    hours_diff = ((datetime.utc - Time.now.utc) / 1.hours).round
    hours_diff >= 24
  end
end
