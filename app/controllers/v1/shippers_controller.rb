module V1
  class ShippersController < ApplicationController
    def last_location
      current_location = driver.last_location

      render json: current_location
    end

    private

    def driver
      @driver ||= Shipper.find(params[:shipper_id])
    end
  end
end
