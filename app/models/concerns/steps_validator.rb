class StepsValidator < ActiveModel::Validator
  def validate(record)
    return record.errors.add(:steps, 'can not be empty') if record.steps.size == 0
    return record.errors.add(:steps, 'all steps must have an action') unless record.steps.all? { |s| s['action'] }
    return record.errors.add(:steps, 'invalid number of steps') if record.steps.size.odd?

    unless same_pickup_and_deliveries? record.steps
      return record.errors.add(:steps,
                               'pickup and deliver should have the same size')
    end
    return record.errors.add(:steps, 'invalid action values') unless record.steps.all? do |s|
                                                                       %w[deliver pickup].include? s['action']
                                                                     end

    unless record.steps.first['action'] == 'pickup'
      record.errors.add(:steps,
                        'the first step action must be pickup')
    end
  end

  def same_pickup_and_deliveries?(steps)
    steps.select { |s| s['action'] == 'pickup' }.size == steps.select { |s| s['action'] == 'deliver' }.size
  end
end
