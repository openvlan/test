class TripMailer < ApplicationMailer # rubocop:disable Metrics/ClassLength
  def buyer_trip_canceled_email(step)
    @order_id = step['marketplace_order_id']
    @order = MarketplaceOrder.find(@order_id)
    @step_action = step['action']
    @location = step['address']
    @user = UserApiCompany.find(@order.buyer_company_id).users.first
    subject = I18n.t('user_mailer.trip_canceled_email.subject')

    send_mail(to: @user.email, subject: subject)
  end

  def seller_trip_canceled_email(step)
    @order_id = step['marketplace_order_id']
    @order = MarketplaceOrder.find(@order_id)
    @step_action = step['action']
    @location = step['address']
    @user = UserApiCompany.find(@order.seller_company_id).users.first
    subject = I18n.t('user_mailer.trip_canceled_email.subject')

    send_mail(to: @user.email, subject: subject)
  end

  def driver_trip_canceled_email(trip)
    return if trip.shipper_id.nil?

    @trip = trip
    @steps = trip.steps
    @user = User.find(Shipper.find(trip.shipper_id).user_id)
    subject = I18n.t('user_mailer.driver_trip_canceled_email.subject')

    send_mail(to: @user.email, subject: subject)
  end

  def driver_trip_refused_email(trip)
    return if trip.shipper_id.nil?

    @trip = trip
    subject = I18n.t('user_mailer.driver_trip_refused_email.subject')

    send_mail(to: LOGISTIC_ADMIN_FULL_EMAIL, subject: subject)
  end

  def driver_trip_assigned_email(shipper)
    @view_trip_link = DynamicLinksService.new.create_link('/trip-list/pending')
    send_mail(
      to: shipper.user.email,
      subject: I18n.t('user_mailer.driver_trip_assigned_email.subject')
    )
  end

  def buyer_trip_scheduled_email(step, start_date, driver)
    order = MarketplaceOrder.find(step['marketplace_order_id'])

    @start_date = start_date.in_time_zone.strftime('%m/%d/%Y')
    @location = step['address']
    @driver = driver
    @user = UserApiCompany.find(order.buyer_company_id).users.first
    subject = I18n.t('user_mailer.scheduled_trip.subject', order_id: order.id)

    send_mail(to: @user.email, subject: subject)
  end

  def seller_trip_scheduled_email(step, start_date, driver)
    order = MarketplaceOrder.find(step['marketplace_order_id'])

    @start_date = start_date.in_time_zone.strftime('%B %d, %Y')
    @location = step['address']
    @driver = driver
    @user = UserApiCompany.find(order.seller_company_id).users.first
    subject = I18n.t('user_mailer.scheduled_trip.subject', order_id: order.id)

    send_mail(to: @user.email, subject: subject)
  end

  def driver_is_on_the_way_buyer_email(step, driver)
    order = MarketplaceOrder.find(step['marketplace_order_id'])

    @driver = driver
    @user = UserApiCompany.find(order.buyer_company_id).users.first
    subject = I18n.t('user_mailer.driver_is_on_the_way.subject', order_id: order.id)

    send_mail(to: @user.email, subject: subject)
  end

  def driver_is_on_the_way_seller_email(step, driver)
    order = MarketplaceOrder.find(step['marketplace_order_id'])

    @driver = driver
    @user = UserApiCompany.find(order.seller_company_id).users.first
    subject = I18n.t('user_mailer.driver_is_on_the_way.subject', order_id: order.id)

    send_mail(to: @user.email, subject: subject)
  end

  def order_delivered_buyer_email(marketplace_order_id)
    order = MarketplaceOrder.find(marketplace_order_id)
    @user = UserApiCompany.find(order.buyer_company_id).users.first
    subject = I18n.t('user_mailer.order_delivered.subject', order_id: order.id)

    send_mail(to: @user.email, subject: subject)
  end

  def order_delivered_seller_email(marketplace_order_id)
    order = MarketplaceOrder.find(marketplace_order_id)
    @user = UserApiCompany.find(order.seller_company_id).users.first
    subject = I18n.t('user_mailer.order_delivered.subject', order_id: order.id)

    send_mail(to: @user.email, subject: subject)
  end

  def seller_notice_shipper_changed(marketplace_order_id)
    @order = MarketplaceOrder.find(marketplace_order_id)
    @user = UserApiCompany.find(@order.seller_company_id).users.first
    subject = I18n.t('user_mailer.shipper_changed.subject')

    send_mail(to: @user.email, subject: subject)
  end

  def buyer_notice_shipper_changed(marketplace_order_id)
    @order = MarketplaceOrder.find(marketplace_order_id)
    @user = UserApiCompany.find(@order.buyer_company_id).users.first
    subject = I18n.t('user_mailer.shipper_changed.subject')

    send_mail(to: @user.email, subject: subject)
  end

  def seller_notice_shipper_cancelled_near_delivery_time(marketplace_order_id)
    @order = MarketplaceOrder.find(marketplace_order_id)
    @user = UserApiCompany.find(@order.seller_company_id).users.first
    subject = I18n.t('user_mailer.shipper_changed.subject_reschedule')

    send_mail(to: @user.email, subject: subject)
  end

  def buyer_notice_shipper_cancelled_near_delivery_time(marketplace_order_id)
    @order = MarketplaceOrder.find(marketplace_order_id)
    @user = UserApiCompany.find(@order.buyer_company_id).users.first
    subject = I18n.t('user_mailer.shipper_changed.subject_reschedule')

    send_mail(to: @user.email, subject: subject)
  end

  def notify_logistics_trip_reschedule(old_trip, new_trip)
    @old_trip = old_trip
    @new_trip = new_trip
    subject = I18n.t('user_mailer.shipper_changed.logistics.subject', old_trip_number: old_trip.trip_number)

    send_mail(to: LOGISTIC_ADMIN_FULL_EMAIL, subject: subject, with_bbc: false)
  end

  def notify_logistics_trip_cancelled_near_starting_time(trip)
    @trip = trip
    @trip_planner_route = '/orders/planner'
    @backoffice_url = Rails.application.secrets.tiko_backoffice_app
    subject = I18n.t('user_mailer.shipper_changed.logistics.subject', old_trip_number: trip.trip_number)

    send_mail(to: LOGISTIC_ADMIN_FULL_EMAIL, subject: subject, with_bbc: false)
  end
end
