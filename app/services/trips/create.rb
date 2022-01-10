module Trips
  class Create
    prepend Service::Base

    def initialize(allowed_params, creator_user)
      @allowed_params = allowed_params
      @shipper = load_shipper(@allowed_params[:shipper_id]) if @allowed_params[:shipper_id]
      @creator_user = creator_user
    end

    def call
      load_orders
      return if errors.any?

      ensure_non_asigned_orders
      return if errors.any?

      create_trip
    end

    private

    def load_orders
      order_ids = @allowed_params[:steps].map { |step| step[:marketplace_order_id] }.uniq
      @orders = Order.where(marketplace_order_id: order_ids)
      unless order_ids.size == @orders.size
        errors.add(
          :orders,
          I18n.t(
            'services.create_trip.order.missing_or_invalid',
            id: order_ids
          )
        )
      end
    end

    def ensure_non_asigned_orders
      if @orders.any? { |order| order.assigned? }
        errors.add(
          :assign,
          I18n.t('services.create_trip.order.already_assigned')
        )
      end
    end

    def create_trip
      begin
        Raven.capture do
          ActiveRecord::Base.transaction do
            start_datetime_params = @allowed_params.extract!(:start_date_string, :start_time_string)
            @trip = Trip.build_manually(
              @allowed_params.merge(creator_user: @creator_user)
            )
            @trip.update_timezone_name
            @trip.set_start_datetime(
              start_datetime_params[:start_date_string],
              start_datetime_params[:start_time_string]
            )

            @trip.orders << @orders

            @trip.save!

            TripMailer.driver_trip_assigned_email(@shipper).deliver if @shipper
            Notifications::Push.new(@trip).call

            @trip.reload
          end
        end
      rescue Service::Error, ActiveRecord::RecordInvalid => e
        errors.add_multiple_errors(exception_errors(e))
        return
      end
    end

    private

    def load_shipper(id)
      if shipper = Shipper.find_by(id: id) # rubocop:todo Lint/AssignmentInCondition
        shipper
      else
        errors.add(:type, I18n.t('services.create_trip.shipper.missing_or_invalid', id: id)) && nil
      end
    end
  end
end
