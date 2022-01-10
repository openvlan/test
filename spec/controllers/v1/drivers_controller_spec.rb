require 'rails_helper'

RSpec.describe V1::DriversController do
  before do
    allow_any_instance_of(User).to receive_messages(save: true)
    allow_any_instance_of(Shipper).to receive(:set_user_role_network_id) { nil }
  end

  before do
    mock_current_user(current_user)
    allow(current_driver).to receive_messages(user: current_user)
    allow(User).to receive(:find_by).with(id: current_driver.user_id) { current_user }
  end

  describe '#update_me' do
    let(:current_driver) { create(:shipper) }
    let(:current_user) { build(:user, id: current_driver.user_id) }

    it 'changes phone number from nil to a new value' do
      expect(current_driver.phone_num).to(be_nil)

      new_number = '+5491111111111'
      post 'update_me', params: { phone_num: new_number }

      expect(response).to have_http_status :ok
      expect(Shipper.find(current_driver.id).phone_num).to(eq(new_number))
    end

    it 'changes phone number from some value to a new one' do
      old_number = '+5491100000000'
      current_driver.phone_num = old_number
      expect(current_driver.phone_num).to(eq(old_number))

      new_number = '+5491111111111'
      post 'update_me', params: { phone_num: new_number }

      expect(response).to have_http_status :ok
      expect(Shipper.find(current_driver.id).phone_num).to(eq(new_number))
    end

    it 'changes only phone number' do
      expect(current_driver.active).to(eq(false))

      post 'update_me', params: { active: true }

      expect(response).to have_http_status :ok
      expect(Shipper.find(current_driver.id).active).to(eq(false))
    end
  end

  describe '#create' do
    let(:current_driver) { create(:shipper) }
    let(:current_user) { build(:user, id: current_driver.user_id) }

    def test_driver_creation(additional_request_params) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      first_name = 'First Name'
      last_name = 'Last Name'
      email = 'email@gmail.com'
      user_id = 'f8245403-703f-4f0d-974f-ec23f818391e'
      user = double(:user, id: user_id, email: email, code: 123)
      password = '12345'
      expect(SecureRandom).to(receive(:hex).and_return(password))
      expect(User).to(
        receive(:create_driver).with(
          ActionController::Parameters.new(
            first_name: first_name,
            last_name: last_name,
            email: email,
            password: password
          ).permit(:first_name, :last_name, :email, :password)
        ).and_return(user)
      )

      allow(user).to receive(:phone=) { nil }
      allow(user).to receive(:phone) { additional_request_params[:phone_num] }
      allow(user).to receive(:save) { true }
      allow(user).to receive(:destroy) { true }

      allow(User).to receive(:find_by).with(id: user_id) { user }

      post 'create', params: {
        first_name: first_name,
        last_name: last_name,
        email: email
      }.merge(additional_request_params)

      expect(response).to have_http_status :ok
      response_body = JSON.parse(response.body)['shipper']
      created_shipper = Shipper.find(response_body['id'])
      expect(created_shipper.first_name).to(eq(first_name))
      expect(created_shipper.last_name).to(eq(last_name))
      expect(created_shipper.user_id).to(eq(user_id))
      created_shipper
    end

    it 'creates a driver with the minimum required attributes, with disabled status' do
      created_shipper = test_driver_creation(provided_services: [:ltl])
      expect(created_shipper.provided_services).to(eq(['ltl']))
      expect(created_shipper.status).to(eq('disabled'))
    end

    # rubocop:disable Naming/VariableNumber
    it 'creates a driver with all available attributes, overriding status to disabled' do
      birth_date_string = '2000-06-01'
      phone_num = '+198765432'
      provided_services = %w[ltl drayage]
      working_hours = {
        weekend: [
          'saturday'
        ],
        workweek: %w[
          tuesday
          thursday
        ],
        to_weekend: '21',
        to_workweek: '21',
        from_weekend: '2',
        from_workweek: '2'
      }.with_indifferent_access
      license_number = '303456'
      license_state = 'license state'
      license_expiration_date = '2021-06-30T12:00:16.560-04:00'
      vehicle_truck_type = 'box'
      vehicle_year = 1934
      vehicle_make = '1432'
      vehicle_model = '32132'
      vehicle_color = 'blue'
      vehicle_license_plate = '2312FR'
      gross_vehicle_weight_rating = 123
      vehicle_insurance_provider = 'provider'
      vehicle_has_liftgate = false
      vehicle_has_forklift = true
      company_name = 'company name'
      company_ein = 827_367_382
      company_max_distance_from_base = '1001.0'
      company_usdot = 123
      company_mc_number = 283_844_884
      company_mc_number_type = 'FF'
      company_sacs_number = '32894732'
      address_street_1 = 'Jerónimo Salguero 1916'
      address_street_2 = 'Bonpland 2281'
      address_zip_code = 'C1425'
      address_city = 'New York'
      address_state = 'Buenos Aires'
      address_country = 'Argentina'
      address_notes = 'notes'
      address_gps_coordinates = nil
      address_formatted_address = 'Jerónimo Salguero 1916, C1425 CABA, Argentina'
      created_shipper = test_driver_creation(
        status: 'Active',
        birth_date: birth_date_string,
        phone_num: phone_num,
        provided_services: provided_services,
        working_hours: working_hours,
        license_attributes: {
          number: license_number,
          state: license_state,
          expiration_date: license_expiration_date
        },
        vehicle_attributes: {
          truck_type: vehicle_truck_type,
          year: vehicle_year,
          make: vehicle_make,
          model: vehicle_model,
          color: vehicle_color,
          license_plate: vehicle_license_plate,
          gross_vehicle_weight_rating: gross_vehicle_weight_rating,
          insurance_provider: vehicle_insurance_provider,
          has_liftgate: vehicle_has_liftgate,
          has_forklift: vehicle_has_forklift
        },
        company_attributes: {
          name: company_name,
          ein: company_ein,
          max_distance_from_base: company_max_distance_from_base.to_f,
          usdot: company_usdot,
          mc_number: company_mc_number,
          mc_number_type: company_mc_number_type,
          sacs_number: company_sacs_number,
          address_attributes: {
            street_1: address_street_1,
            street_2: address_street_2,
            zip_code: address_zip_code,
            city: address_city,
            state: address_state,
            country: address_country,
            notes: address_notes,
            gps_coordinates: address_gps_coordinates,
            formatted_address: address_formatted_address
          }
        }
      )
      expect(created_shipper.status).to(eq('disabled'))
      expect(created_shipper.birth_date).to(eq(Date.parse(birth_date_string)))
      expect(created_shipper.phone_num).to(eq(phone_num))
      expect(created_shipper.provided_services).to(eq(provided_services))
      expect(created_shipper.working_hours).to(eq(working_hours))
      license = created_shipper.license
      expect(license.number).to(eq(license_number))
      expect(license.state).to(eq(license_state))
      expect(license.expiration_date).to(eq(license_expiration_date))
      vehicle = created_shipper.vehicle
      expect(vehicle.truck_type).to(eq(vehicle_truck_type))
      expect(vehicle.year).to(eq(vehicle_year))
      expect(vehicle.make).to(eq(vehicle_make))
      expect(vehicle.model).to(eq(vehicle_model))
      expect(vehicle.color).to(eq(vehicle_color))
      expect(vehicle.license_plate).to(eq(vehicle_license_plate))
      expect(vehicle.gross_vehicle_weight_rating).to(eq(gross_vehicle_weight_rating))
      expect(vehicle.insurance_provider).to(eq(vehicle_insurance_provider))
      expect(vehicle.has_liftgate).to(eq(vehicle_has_liftgate))
      expect(vehicle.has_forklift).to(eq(vehicle_has_forklift))
      company = created_shipper.company
      expect(company.name).to(eq(company_name))
      expect(company.ein).to(eq(company_ein))
      expect(company.max_distance_from_base.to_s).to(eq(company_max_distance_from_base))
      expect(company.usdot).to(eq(company_usdot))
      expect(company.mc_number).to(eq(company_mc_number))
      expect(company.mc_number_type).to(eq(company_mc_number_type))
      expect(company.sacs_number).to(eq(company_sacs_number))
      address = company.address
      expect(address.street_1).to(eq(address_street_1))
      expect(address.street_2).to(eq(address_street_2))
      expect(address.zip_code).to(eq(address_zip_code))
      expect(address.city).to(eq(address_city))
      expect(address.state).to(eq(address_state))
      expect(address.country).to(eq(address_country))
      expect(address.notes).to(eq(address_notes))
      expect(address.gps_coordinates).to(eq(address_gps_coordinates))
      expect(address.formatted_address).to(eq(address_formatted_address))
    end
    # rubocop:enable Naming/VariableNumber
  end

  context '/v1/drivers/me/default_payment_method' do
    let(:current_driver) { create(:shipper) }
    let(:current_user) { build(:user, id: current_driver.user_id) }

    describe 'GET' do
      it "shows current driver's payment method if it exists" do
        attributes = {
          'payment_method' => PaymentMethod::PAYPAL,
          'payment_email' => 'asd@qwe.com',
          'shipper_id' => current_driver.id
        }
        create(:payment_method, attributes)
        get 'show_my_default_payment_method'
        expect(response).to(have_http_status(:success))
        expect(JSON.parse(response.body)).to(include(attributes))
      end

      it "returns not found status if driver's payment method doesn't exist" do
        get 'show_my_default_payment_method'
        expect(response).to(have_http_status(:not_found))
      end
    end

    describe 'POST' do
      let(:current_driver) { create(:shipper) }
      let(:current_user) { build(:user, id: current_driver.user_id) }

      it "creates a payment method for current driver if there's not one" do
        attributes = { 'payment_method' => PaymentMethod::ACH }
        post 'create_my_default_payment_method', params: attributes
        expect(response).to(have_http_status(:success))
        expect(JSON.parse(response.body)).to(include(attributes))
        payment_method = current_driver.payment_method
        expect(payment_method.payment_method).to(eq(PaymentMethod::ACH))
        expect(payment_method.payment_email).to(eq(nil))
      end

      it 'gives an error if current driver already has a payment method' do
        create(:payment_method, shipper: current_driver)
        expect do
          post 'create_my_default_payment_method', params: { payment_method: PaymentMethod::ACH }
        end.to(raise_error(ActiveRecord::RecordNotUnique))
      end

      it 'gives an error if the params are invalid' do
        expect do
          post 'create_my_default_payment_method', params: { payment_method: PaymentMethod::PAYPAL }
        end.to(raise_error(ActiveRecord::RecordInvalid, "Validation failed: Payment email can't be blank"))
      end
    end

    describe 'PUT' do
      let(:current_driver) { create(:shipper) }
      let(:current_user) { build(:user, id: current_driver.user_id) }

      it "returns not found status if driver's payment method doesn't exist" do
        expect(PaymentMethodMailer).not_to(receive(:with))
        put 'update_my_default_payment_method', params: { payment_method: PaymentMethod::ACH }
        expect(response).to(have_http_status(:not_found))
      end

      it "updates driver's payment method" do
        expect_any_instance_of(PaymentMethodMailer).to(receive(:driver_payment_method_has_been_updated))
        create(:payment_method, shipper: current_driver, payment_method: PaymentMethod::ACH)
        new_email = 'asd@qwe.com'
        attributes = { 'payment_method' => PaymentMethod::PAYPAL, 'payment_email' => new_email }
        put 'update_my_default_payment_method', params: attributes
        expect(response).to(have_http_status(:success))
        expect(JSON.parse(response.body)).to(include(attributes))
        payment_method = current_driver.payment_method.reload
        expect(payment_method.payment_method).to(eq(PaymentMethod::PAYPAL))
        expect(payment_method.payment_email).to(eq(new_email))
      end

      it 'gives an error if the params are invalid' do
        expect(PaymentMethodMailer).not_to(receive(:with))
        create(:payment_method, shipper: current_driver, payment_method: PaymentMethod::ACH)
        expect do
          put 'update_my_default_payment_method', params: { payment_method: PaymentMethod::PAYPAL }
        end.to(raise_error(ActiveRecord::RecordInvalid, "Validation failed: Payment email can't be blank"))
      end
    end
  end
end
