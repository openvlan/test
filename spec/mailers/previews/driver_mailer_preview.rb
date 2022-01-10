# Preview all emails at http://localhost:3030/rails/mailers/driver_mailer
class DriverMailerPreview < ActionMailer::Preview
  def driver_disabled_email
    DriverMailer.driver_disabled_email(User.last)
  end

  def driver_approved_email
    DriverMailer.driver_approved_email(User.last)
  end

  def driver_rejected_email
    DriverMailer.driver_rejected_email(User.last)
  end

  def driver_pending_email
    DriverMailer.driver_pending_email(User.last)
  end

  def driver_awaiting_vetting_email
    DriverMailer.driver_awaiting_vetting_email(Shipper.first)
  end
end
