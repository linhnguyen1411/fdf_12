class OrderProductService

  def initialize updated_orders, shop
    @updated_orders = updated_orders
    @shop = shop
  end

  def update_order_product
    @order_products_rejected = @shop.order_products.rejected
    @updated_orders.each do |order|
      done_products = order.order_products.done.size
      rejected_products = order.order_products.rejected.size
      order.create_event_done done_products, rejected_products
    end
  end

  def send_message_to_chatwork
    SendOrdersInfoToChatworkJob.perform_later @updated_orders 
  end
end
