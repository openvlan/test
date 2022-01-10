module Shippers
  class UpdateStatus
    prepend Service::Base

    def initialize(driver, status_params)
      @driver = driver
      @status = status_params[:status]
      @audit_comment = status_params[:audit_comment]

      @status_event = {
        rejected: 'reject',
        active: 'activate',
        disabled: 'disabled'
      }
    end

    def call
      update_driver_status
    end

    private

    def update_driver_status
      event = @status_event[@status.to_sym]
      return errors.add(:status, 'Unknwon status') unless event

      Shipper.transaction do
        @driver.send("#{event}!")
        @driver.audits.last.update!(comment: @audit_comment)
      end
    rescue AASM::InvalidTransition => e
      errors.add_multiple_errors({ invalid_transition: [e] })
    end
  end
end
