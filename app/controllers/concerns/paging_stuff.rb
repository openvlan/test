# pagination

# Internal: Ability to handle soma pagination logic
module PagingStuff
  extend ActiveSupport::Concern

  private

  # This is a hack because of a timming situation in which we include the pagination
  # logic, but the frontend applications are not ready to handle it properly.
  # So for now if you want the results with pagination you should send the params[:page]
  # no matter if it's the first page, in that case you should send https://...?page=1
  def list_results(dataset)
    params[:page] ? paginate(dataset) : dataset
  end
end
