class AddAutoincrementFieldOnTrips < ActiveRecord::Migration[5.2]
  def self.up
    add_column :trips, :trip_number, :bigint
    execute <<-SQL
     CREATE SEQUENCE trip_number_seq START 1;
     ALTER SEQUENCE trip_number_seq OWNED BY trips.trip_number;
     ALTER TABLE trips ALTER COLUMN trip_number SET DEFAULT nextval('trip_number_seq');
    SQL
  end


  def self.down
    remove_column :trips, :trip_number
    execute <<-SQL
      DROP SEQUENCE trip_number_seq;
    SQL
  end
end
