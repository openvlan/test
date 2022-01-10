class CreateDriver
  prepend Service::Base

  def initialize(driver_params, current_user)
    @driver_params = driver_params
    @current_user = current_user
  end

  def call
    create_driver
  end

  private

  def create_driver # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
    user = User.create_driver(
      @driver_params.slice(:first_name, :last_name, :email).merge(password: SecureRandom.hex)
    )
    begin
      shipper = Shipper.new
      shipper.user_id = user.id

      service = UpdateDriver.call(shipper, @driver_params, false, @current_user.id)
      unless service.success?
        user.destroy
        errors.add_multiple_errors(service.errors)
        return
      end

      shipper = service.result
      shipper.status = :disabled
      shipper.save!
      shipper
    rescue StandardError => e
      user.destroy
      raise e
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add_multiple_errors(e.record.errors.messages)
  rescue StandardError => e
    errors.add(:error, e.exception)
  end
end
