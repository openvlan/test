require 'api_utils'

class CleanupController < ApiUtils::BaseController
  def clean_database
    return render :bad_request if Rails.env.production?

    tables = ActiveRecord::Base.connection.tables
    tables.delete 'schema_migrations'
    tables.each do |t|
      ActiveRecord::Base.connection.execute("TRUNCATE #{t} CASCADE")
    end

    Rails.application.load_seed

    render :ok
  end
end
