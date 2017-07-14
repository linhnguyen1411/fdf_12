class OrdersService

  def initialize orders, shop
    @orders = orders
    @shop = shop
  end

  def update_status
    order_products = OrderProduct.all_order_product_of_list_orders(@orders.ids).accepted
    ActiveRecord::Base.transaction do
      order_products.each do |order_product|
        order_product.update_attributes status: :done
      end
      @orders.each do |order|
        order.update_attributes status: :done, end_at: Time.now
      end
      order_service = OrderProductService.new(@orders, @shop)
      order_service.update_order_product
      order_service.send_message_to_chatwork
      [Settings.api_type_success, I18n.t("flash.success.update_order")]
    end
    rescue
      return [Settings.api_type_error, I18n.t("can_not_update_order")]
  end
end
