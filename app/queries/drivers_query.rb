class DriversQuery
  include Sortable

  def table(params)
    query(params)
  end

  private

  def query(params)
    result = basic_query(params)
    result = result.order(status: :asc) if params['sort'].nil?
    result
  end

  def basic_query(params)
    query = drivers_searched(params)
            .select("shippers.id, shippers.first_name, shippers.last_name, shippers.status,
               shippers.created_at, shippers.company_id,
               companies.name, addresses.company_id, addresses.id, addresses.city, addresses.state,
               vehicles.truck_type, vehicles.gross_vehicle_weight_rating")
            .order(sorting_params(Shipper, params))
            .order(sorting_params(Address, params))
            .order(sorting_params(Company, params))
            .order(sorting_params(Vehicle, params))

    query = query.where(network_id: params[:network_id]) if params.key?(:network_id)
    query
  end

  def drivers_searched(params) # rubocop:todo Metrics/AbcSize
    return Shipper.with_joins if params[:search].nil? || params[:search].empty?

    return search_by_status(params) unless search_by_status(params).empty?

    return search_by_vehicle_type(params) unless search_by_vehicle_type(params).empty?

    query = Shipper.search(params[:search])

    downcase_search = params[:search].downcase.strip
    Shipper::ProvidedServices::ALL.each do |provided_service|
      if downcase_search == provided_service
        query = query.or(Shipper.where("'#{downcase_search}' = ANY (provided_services)"))
      end
    end

    query.with_joins
  end

  def search_by_status(params)
    Shipper.search_by_status(params[:search]).with_joins
  end

  def search_by_vehicle_type(params)
    type = Vehicle.truck_types[params[:search].downcase.parameterize.underscore]
    return [] if type.nil?

    Shipper.search_by_vehicle_type(type).with_joins
  end
end
