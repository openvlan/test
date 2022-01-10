require 'rails_helper'

describe StartDatetimeValidator do
  def test_validator(start_datetime_iso:, orders:, expected_errors:, timezone_name: 'America/New_York')
    steps = []
    orders.each_with_index do |order, index|
      warehouse_address_id = 2 * index
      delivery_location_id = 2 * index + 1
      allow(UserApiAddress).to(
        receive(:find).with(warehouse_address_id).and_return(
          double(open_hours: double(order[:warehouse_open_hours]))
        )
      )
      allow(UserApiAddress).to(
        receive(:find).with(delivery_location_id).and_return(
          double(open_hours: double(order[:delivery_location_open_hours]))
        )
      )
      allow(Order).to(
        receive(:find_by).with(marketplace_order_id: index).and_return(
          double(
            warehouse_address_id: warehouse_address_id,
            delivery_location_id: delivery_location_id
          )
        )
      )
      steps.push('marketplace_order_id' => index)
    end
    trip = build(
      :trip,
      start_datetime: Time.parse(start_datetime_iso),
      steps: steps,
      timezone_name: timezone_name
    )
    subject.validate(trip)
    expect(trip.errors.as_json).to(eq(expected_errors))
  end

  it 'gives an error when start datetime does not round to 15 minutes' do
    test_validator(
      start_datetime_iso: '2011-10-04T01:16:00-04:00', # tuesday
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 2,
            to_workweek: 5
          },
          delivery_location_open_hours: {
            to_weekend: 4,
            to_workweek: 3
          }
        }
      ],
      expected_errors: {
        start_datetime: ['must round to 15 minutes']
      }
    )
  end

  it 'needs seconds to be 0 for it to be considered rounded to 15 minutes' do
    test_validator(
      start_datetime_iso: '2011-10-05T01:15:33-04:00', # wednesday
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 12,
            to_workweek: 15
          },
          delivery_location_open_hours: {
            to_weekend: 13,
            to_workweek: 14
          }
        }
      ],
      expected_errors: {
        start_datetime: ['must round to 15 minutes']
      }
    )
  end

  it 'gives no error when time is correctly rounded to 15 minutes' do
    %w[00 15 30 45].each do |minutes|
      test_validator(
        start_datetime_iso: "2011-10-06T10:#{minutes}:00-04:00", # thursday
        orders: [
          {
            warehouse_open_hours: {
              to_weekend: 12,
              to_workweek: 15
            },
            delivery_location_open_hours: {
              to_weekend: 13,
              to_workweek: 14
            }
          }
        ],
        expected_errors: {}
      )
    end
  end

  it 'gives an error when the delivery location closes less than 1 hour after start time' do
    test_validator(
      start_datetime_iso: "2011-10-07T10:30:00-04:00", # friday
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 12,
            to_workweek: 15
          },
          delivery_location_open_hours: {
            to_weekend: 13,
            to_workweek: 11
          }
        }
      ],
      expected_errors: {
        start_datetime: ['must be at least 1 hour earlier than minimum closing time of locations in the route: 11:00']
      }
    )
  end

  it 'gives an error when the warehouse location closes less than 1 hour after start time' do
    test_validator(
      start_datetime_iso: "2011-10-08T14:15:05-04:00", # saturday
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 15,
            to_workweek: 20
          },
          delivery_location_open_hours: {
            to_weekend: 20,
            to_workweek: 20
          }
        }
      ],
      expected_errors: {
        start_datetime: [
          'must round to 15 minutes',
          'must be at least 1 hour earlier than minimum closing time of locations in the route: 15:00'
        ]
      }
    )
  end

  it 'checks against the minimum closing hour out of all of the orders' do
    test_validator(
      start_datetime_iso: "2011-10-09T20:00:00-04:00", # sunday
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 22,
            to_workweek: 22
          },
          delivery_location_open_hours: {
            to_weekend: 21,
            to_workweek: 22
          }
        },
        {
          warehouse_open_hours: {
            to_weekend: 20,
            to_workweek: 22
          },
          delivery_location_open_hours: {
            to_weekend: 19,
            to_workweek: 22
          }
        },
        {
          warehouse_open_hours: {
            to_weekend: 18,
            to_workweek: 22
          },
          delivery_location_open_hours: {
            to_weekend: 17,
            to_workweek: 22
          }
        }
      ],
      expected_errors: {
        start_datetime: ['must be at least 1 hour earlier than minimum closing time of locations in the route: 17:00']
      }
    )
  end

  it 'allows exactly 1 hour before closing time' do
    test_validator(
      start_datetime_iso: "2011-10-10T10:00:00-04:00", # monday
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 12,
            to_workweek: 15
          },
          delivery_location_open_hours: {
            to_weekend: 13,
            to_workweek: 11
          }
        }
      ],
      expected_errors: {}
    )
  end


  it 'uses trip timezone name to interpret to_weekend and to_workweek' do
    test_validator(
      start_datetime_iso: "2021-11-08T10:00:00-00:00", # monday 11:00 in Paris
      timezone_name: 'Europe/Paris',
      orders: [
        {
          warehouse_open_hours: {
            to_weekend: 12,
            to_workweek: 15
          },
          delivery_location_open_hours: {
            to_weekend: 13,
            to_workweek: 11
          }
        }
      ],
      expected_errors: {
        start_datetime: ['must be at least 1 hour earlier than minimum closing time of locations in the route: 11:00']
      }
    )
  end
end
