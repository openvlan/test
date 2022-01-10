# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user.roles.map { |role| role['name'] }.each { |role_name| send "add_#{role_name}_abilities" } if user&.active

    add_guest_abilities
  end

  private

  def add_admin_abilities
    can %i[create cancel update confirm_driver start complete], V1::TripsController
    can %i[audits show_by_user_id change_status update add_audit create], V1::DriversController
    can %i[index mark_as_paid], TripPaymentsController
    can %i[index create destroy], TripStepPhotosController
    can %i[last_location], V1::ShippersController
  end

  def add_driver_abilities
    can %i[me update_me onboarding update_my_default_payment_method], V1::DriversController
    can %i[create], TripPaymentsController
    can %i[index trip_history start show milestone complete take pickup cancel], V1::Drivers::TripsController
    can %i[set_current_location has_on_going_trips], V1::Drivers::ShippersController
  end

  def add_buyer_abilities; end

  def add_seller_abilities; end

  def add_guest_abilities
    can %i[list show], V1::TripsController
    can %i[create_my_default_payment_method show_my_default_payment_method update_my_default_payment_method table show],
        V1::DriversController
    can %i[destroy_by_marketplace_order trip_planner], V1::OrdersController
    can %i[index create], TripStepPhotosController
    can %i[take], V1::Drivers::TripsController
    can %i[create show], Resources::OrdersController
    can %i[create statuses_by_user_ids], Services::ShippersController
    can %i[health sentry ping_async], HealthController
    can %i[calculate], V1::DeliveryCostsController
    can %i[clean_database], CleanupController
  end
end
