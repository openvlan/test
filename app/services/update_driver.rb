class UpdateDriver
  prepend Service::Base
  include PhotoPosition
  include PhotoDestroy

  def initialize(driver, driver_params, is_onboarding = false, current_user_id = nil) # rubocop:todo Style/OptionalBooleanParameter
    @driver = driver
    @driver_params = driver_params
    @is_onboarding = is_onboarding
    @user = @driver.user
    @current_user_id = current_user_id
  end

  def call
    update_driver
  end

  private

  # rubocop:todo Metrics/MethodLength
  def update_driver # rubocop:todo Metrics/AbcSize
    @license_photos = @driver_params.dig(:license_attributes, :photos)
    @vehicle_photos = @driver_params.dig(:vehicle_attributes, :photos)
    purge_photos

    @driver_params[:license_attributes][:photos] = new_photos('license_attributes') if @license_photos
    @driver_params[:vehicle_attributes][:photos] = new_photos('vehicle_attributes') if @vehicle_photos

    @driver.assign_attributes(@driver_params.except(:email))
    @driver.save!

    @driver.finish_onboarding! if @is_onboarding

    if should_change_email?
      old_email = @user.email
      @user.email = @driver_params[:email]
      @user.save!
      service = CreateAuditMessage.call(
        @user.id,
        'User',
        nil,
        @current_user_id,
        @driver.id,
        'Shipper',
        { email: [old_email, @driver_params[:email]] }
      )
      return errors.add(:email_adit, service.errors) unless service.success?
    end

    @driver
  rescue ActiveRecord::RecordInvalid => e
    errors.add_multiple_errors(e.record.errors.messages)
  rescue StandardError => e
    errors.add(:error, e.exception)
  end
  # rubocop:enable Metrics/MethodLength

  def should_change_email?
    !@driver_params[:email].nil? && @user&.email != @driver_params[:email]
  end

  def new_photos(key) # rubocop:todo Metrics/AbcSize
    return nil if @driver_params[key.to_sym].nil?

    return nil if @driver_params[key.to_sym][:photos].nil?

    new_photos = @driver_params[key.to_sym][:photos].select { |photo| photo[:url].eql? nil }

    return [] if new_photos.empty?

    new_photos.collect { |photo| photo[:signed_id] }
  end

  def purge_photos
    destroy_photos(@license_photos) unless @license_photos.nil?
    destroy_photos(@vehicle_photos) unless @vehicle_photos.nil?
  end
end
