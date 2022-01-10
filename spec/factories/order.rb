FactoryBot.define do
  factory :order do
    amount { 200 }
    manual_order { true }
    marketplace_order_id { 1 }
    network_id { 1 }
    total_weight_in_lb { 1.1 }
    warehouse_address_id { 'a854ff0b-d655-42cf-84a9-68c8dd8e2405' }
    delivery_location_id { 'c5898a34-599d-4f3f-b3b3-263367e5dc50' }
  end
end
