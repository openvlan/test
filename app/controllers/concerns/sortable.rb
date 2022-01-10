module Sortable
  extend ActiveSupport::Concern

  def sorting_params(model, params)
    # sorting_params(params) # => { status: :desc, last_name: :asc }
    # Shipper.order(status: :desc, last_name: :asc)
    return unless params[:sort]

    sorting = {}

    sorted_params = params[:sort].split(',')
    sorted_params.each do |param|
      splitted_param = param.split('_')
      order_type = splitted_param.pop
      order_attr = splitted_param.join('_')
      sorting[order_attr] = order_type if model.attribute_names.include?(order_attr)
    end

    sorting
  end
end
