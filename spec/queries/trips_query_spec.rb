require 'rails_helper'

describe TripsQuery do
  describe 'list' do
    def test_list(expected_sql:, **list_params)
      active_record_relation = subject.list(**list_params)
      active_record_relation.to_json # throws errors when the query is invalid
      expect(active_record_relation.to_sql.squish).to(eq(expected_sql.squish))
    end

    it 'builds the query' do
      expected_sql = <<~SQL
        SELECT trips.id,
               trips.status,
               trips.steps,
               trips.shipper_id,
               trips.trip_number,
               trips.comments,
               trips.amount,
               trips.distance,
               trips.start_datetime
        FROM "trips"
        WHERE (start_datetime >= '2021-05-28T16:23:33-03:00')
          AND (start_datetime <= '2021-05-30T16:23:33-03:00')
          AND "trips"."status" IN ('2', '4')
        ORDER BY  "trips"."status" ASC, "trips"."start_datetime" ASC
      SQL
      test_list start_datetime: '2021-05-28T16:23:33-03:00',
                end_datetime: '2021-05-30T16:23:33-03:00',
                status: %w[confirmed completed],
                expected_sql: expected_sql
    end

    it 'matches nothing if status array is empty' do
      expected_sql = <<~SQL
        SELECT trips.id,
               trips.status,
               trips.steps,
               trips.shipper_id,
               trips.trip_number,
               trips.comments,
               trips.amount,
               trips.distance,
               trips.start_datetime
        FROM "trips"
        WHERE (start_datetime >= '2021-01-01T00:00:01-01:00')
          AND (start_datetime <= '2021-02-02T00:00:02-02:00')
          AND 1=0
        ORDER BY  "trips"."status" ASC, "trips"."start_datetime" ASC
      SQL
      test_list start_datetime: '2021-01-01T00:00:01-01:00',
                end_datetime: '2021-02-02T00:00:02-02:00',
                status: %w[],
                expected_sql: expected_sql
    end

    it 'requires start_datetime' do
      expect do
        subject.list(
          end_datetime: '2021-05-30T16:23:33-03:00',
          status: %w[confirmed completed]
        )
      end.to(raise_error(ArgumentError, 'missing keyword: start_datetime'))
    end

    it 'requires end_datetime' do
      expect do
        subject.list(
          start_datetime: '2021-01-01T00:00:01-01:00',
          status: %w[confirmed completed]
        )
      end.to(raise_error(ArgumentError, 'missing keyword: end_datetime'))
    end

    it 'requires status' do
      expect do
        subject.list(
          start_datetime: '2021-01-01T00:00:01-01:00',
          end_datetime: '2021-02-02T00:00:02-02:00'
        )
      end.to(raise_error(ArgumentError, 'missing keyword: status'))
    end
  end
end
