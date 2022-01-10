require 'api_utils'

ApiUtils::BaseController.class_eval do
    def allowed_routes
      {
        Resources::OrdersController => [:create],
        V1::Drivers::TripsController => [:take],
        TripStepPhotosController => [:index, :create],
        V1::OrdersController => %i[destroy_by_marketplace_order],
        V1::DriversController => %i[create_my_default_payment_method show_my_default_payment_method update_my_default_payment_method show],
        V1::TripsController => %i[list show],
        Services::ShippersController => %i[create statuses_by_user_ids],
        V1::DeliveryCostsController => %i[calculate]
      }
    end
end
