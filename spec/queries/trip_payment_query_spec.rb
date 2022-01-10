require 'rails_helper'

describe TripPaymentQuery do
  describe 'list' do
    def test_list(expected_sql:, search_text:)
      active_record_relation = subject.list(search_text)
      active_record_relation.to_json # throws errors when the query is invalid
      expect(active_record_relation.to_sql.squish).to(eq(expected_sql.squish))
    end

    it 'searches with shipper name' do
      expected_sql = <<~SQL
        SELECT "trip_payments".*
        FROM "trip_payments"
             LEFT OUTER JOIN "trips" ON "trips"."id" = "trip_payments"."trip_id"
             LEFT OUTER JOIN "shippers" ON "shippers"."id" = "trips"."shipper_id"
        WHERE ((((lower(shippers.first_name) LIKE '%pepe%')
           OR (lower(shippers.last_name) LIKE '%pepe%'))
           OR (lower(confirmation_code) LIKE '%pepe%'))
           OR (lower(payment_email) LIKE '%pepe%'))
        ORDER BY trips.start_datetime desc
      SQL
      test_list search_text: 'pepe',
                expected_sql: expected_sql
    end

    it 'searches with trip number' do
      trip_number = '123123'
      expected_sql = <<~SQL
        SELECT "trip_payments".*
        FROM "trip_payments"
             LEFT OUTER JOIN "trips" ON "trips"."id" = "trip_payments"."trip_id"
             LEFT OUTER JOIN "shippers" ON "shippers"."id" = "trips"."shipper_id"
        WHERE (((((lower(shippers.first_name) LIKE '%123123%')
           OR (lower(shippers.last_name) LIKE '%123123%'))
           OR (lower(confirmation_code) LIKE '%123123%'))
           OR (lower(payment_email) LIKE '%123123%'))
           OR "trips"."trip_number" = 123123)
        ORDER BY trips.start_datetime desc
      SQL
      test_list search_text: "\n #{trip_number}\n",
                expected_sql: expected_sql
    end

    it 'searches with no params' do
      expected_sql = <<~SQL
        SELECT "trip_payments".*
        FROM "trip_payments"
             LEFT OUTER JOIN "trips" ON "trips"."id" = "trip_payments"."trip_id"
             LEFT OUTER JOIN "shippers" ON "shippers"."id" = "trips"."shipper_id"
        ORDER BY trips.start_datetime desc
      SQL
      test_list search_text: '',
                expected_sql: expected_sql
    end
  end
end
