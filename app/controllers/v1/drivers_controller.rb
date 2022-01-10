module V1
  class DriversController < ApplicationController # rubocop:todo Metrics/ClassLength
    include PhotoPosition
    skip_around_action :transactions_filter, only: %i[onboarding]
    before_action :set_default_network_id, only: [:table]

    def onboarding # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      unless current_driver
        return render json: { errors: I18n.t('errors.not_found.driver', id: current_driver.id) },
                      status: :not_found
      end

      errors = nil
      ActiveRecord::Base.transaction do
        service = UpdateDriver.call(current_driver, update_driver_params, true)
        unless service.success?
          errors = service.errors
          raise ActiveRecord::Rollback
        end

        unless update_driver_params[:license_attributes][:photos].nil?
          save_photo_position(update_driver_params[:license_attributes][:photos])
        end
        unless update_driver_params[:vehicle_attributes][:photos].nil?
          save_photo_position(update_driver_params[:vehicle_attributes][:photos])
        end

        # rubocop:disable Style/RescueStandardError
        begin
          Shippers::Emails::Onboarding.new(current_driver).call
        rescue => e
          errors = 'Something went wrong'
          Raven.capture_exception(e)
          raise ActiveRecord::Rollback
        end
        # rubocop:enable Style/RescueStandardError
      end

      if errors
        render json: { errors: errors }, status: :unprocessable_entity
      else
        render status: :ok
      end
    end

    def table
      query = DriversQuery.new
      drivers_table = paginate query.table(params), per_page: params[:per_page]
      result = ActiveModelSerializers::
                SerializableResource.new(drivers_table,
                                         each_serializer: V1::DriversTableSerializer,
                                         root: 'items').as_json

      render json: result.merge(total_count: drivers_table.total_count, total_pages: drivers_table.total_pages)
    end

    def show
      return render status: :not_found if driver.nil?

      render json: driver, serializer: V1::Backoffice::DriverSerializer
    end

    def show_by_user_id
      driver = Shipper.find_by(user_id: params[:id])

      return render status: :not_found if driver.nil?

      render json: driver, serializer: V1::Backoffice::DriverSerializer
    end

    def update
      return render status: :not_found if driver.nil?

      service = UpdateDriver.call(driver, update_driver_params, false, @current_user.id)
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      update_photo_positions
      render status: :ok
    end

    def create
      service = CreateDriver.call(update_driver_params.merge(audit_comment: 'Driver manually created'), @current_user)
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      update_photo_positions
      render json: service.result
    end

    def audits
      return render status: :not_found if driver.nil?

      audits = (
        driver.all_audits
      ).sort_by(&:created_at).reverse

      render json: if audits.empty?
                     { "audited/audits": [] }
                   else
                     ActiveModelSerializers::SerializableResource.new(
                       audits,
                       each_serializer: V1::AuditSerializer
                     ).as_json
                   end,
             status: :ok
    end

    def add_audit
      return render status: :not_found if driver.nil?

      audit = CreateAuditMessage.call(driver.id, 'Shipper', params[:comment], @current_user.id)
      return render json: { errors: audit.errors }, status: :unprocessable_entity unless audit.success?

      render status: :ok
    end

    def change_status # rubocop:todo Metrics/AbcSize
      return render status: :not_found if driver.nil?

      service = Shippers::UpdateStatus.new(driver, status_params).call
      return render json: { errors: service.errors }, status: :unprocessable_entity unless service.success?

      Shippers::Emails::Status.new(driver).call if params[:driver][:send_email]

      render status: :ok
    end

    def me
      return render status: :not_found if current_driver.nil?

      render json: current_driver, serializer: V1::DriversMeSerializer
    end

    def update_me
      render current_driver.update!(params.permit(:phone_num))
    end

    def show_my_default_payment_method
      payment_method = current_driver.payment_method
      render payment_method ? { json: payment_method } : { status: :not_found }
    end

    def create_my_default_payment_method
      render json: PaymentMethod.create!(payment_method_params.merge(shipper: current_driver))
    end

    def update_my_default_payment_method
      payment_method = current_driver.payment_method
      render status: :not_found and return unless payment_method

      payment_method.update!(payment_method_params)
      PaymentMethodMailer.with(
        driver: current_driver,
        payment_method: payment_method
      ).driver_payment_method_has_been_updated.deliver
      render json: payment_method
    end

    private

    def payment_method_params
      params.permit(:payment_method, :payment_email)
    end

    def update_photo_positions
      unless update_driver_params.dig(:license_attributes, :photos).nil?
        save_photo_position(update_driver_params[:license_attributes][:photos])
      end
      return if update_driver_params.dig(:vehicle_attributes, :photos).nil?

      save_photo_position(update_driver_params[:vehicle_attributes][:photos])
    end

    def driver
      @driver ||= Shipper.find_by(id: params[:id])
    end

    def current_driver
      @current_driver ||= Shipper.find_by(user_id: current_user.id)
    end

    def status_params
      params.require(:driver).permit(
        :status, :audit_comment
      )
    end

    def update_driver_params
      params.permit(
        :id,
        :first_name,
        :last_name,
        :email,
        :phone_num,
        :birth_date,
        provided_services: [],
        working_hours: {},
        vehicle_attributes: Vehicle::ATTRIBUTES,
        license_attributes: License::ATTRIBUTES,
        company_attributes: [
          :id, :name, :ein, :max_distance_from_base, :usdot, :mc_number, :mc_number_type, :sacs_number,
          { address_attributes: Address::ATTRIBUTES }
        ]
      )
    end

    def sort_photos
      return if @driver_params[:license_attributes][:photos].nil?

      save_photo_position(@driver_params[:license_attributes][:photos])
    end
  end
end
