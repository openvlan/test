require 'rails_helper'

RSpec.describe V1::OrdersController do
  describe '#destroy_by_marketplace_order' do
    it 'gives ok status code when successful' do
      order = create(:order)
      post 'destroy_by_marketplace_order', params: { id: order.marketplace_order_id }
      expect(response).to have_http_status :ok
      expect { Order.find(order.id) }.to(raise_error(ActiveRecord::RecordNotFound))
    end
  end
end
