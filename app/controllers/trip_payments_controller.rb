class TripPaymentsController < ApplicationController
  before_action :set_default_network_id, only: [:index]

  def create
    trip = Trip.find_by_id(params[:trip_id])

    error_response = validate_for_create(trip)
    return error_response if error_response

    trip_payment = TripPayment.create!(params.permit(:trip_id, :payment_method, :payment_email))

    send_payment_pending_emails(trip_payment)

    render json: trip_payment
  end

  def mark_as_paid
    confirmation_code = params[:confirmation_code]
    trip_payment = TripPayment.find(params[:id])

    error_response = validate_for_mark_as_paid(confirmation_code, trip_payment)
    return error_response if error_response

    payment = TripPayment.update(params[:id], confirmation_code: confirmation_code, paid_at: DateTime.now)
    trip_payment.trip.log_payment_paid(current_user)
    render json: payment
  end

  def index
    payments = TripPaymentQuery.new.list(params[:search], params[:network_id])
    paginated_payments = paginate(payments, per_page: params[:per_page])
    result = ActiveModelSerializers::SerializableResource.new(
      paginated_payments,
      each_serializer: TripPaymentSerializer,
      root: 'items'
    ).as_json
    render json: result.merge(total_count: paginated_payments.total_count, total_pages: paginated_payments.total_pages)
  end

  private

  def send_payment_pending_emails(trip_payment)
    %i[driver_payment_pending tiko_employee_payment_pending].each do |email|
      TripPaymentMailer.with(trip_payment: trip_payment).send(email).deliver
    end
  end

  def validate_for_create(trip)
    return render status: :not_found if !trip || trip.shipper.user.id != current_user.id

    if trip.status != 'completed'
      return render json: { errors: [I18n.t('errors.params.trip_payments.trip_was_not_completed')] },
                    status: :bad_request
    end

    nil
  end

  def validate_for_mark_as_paid(confirmation_code, trip_payment)
    if confirmation_code.blank?
      return render json: { errors: [I18n.t('errors.params.trip_payments.missing_confirmation_code')] },
                    status: :bad_request
    end

    if trip_payment.confirmation_code.present?
      return render json: { errors: [I18n.t('errors.params.trip_payments.confirmation_code_already_present')] },
                    status: :bad_request
    end

    nil
  end
end
