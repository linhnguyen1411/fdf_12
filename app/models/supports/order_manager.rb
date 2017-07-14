module Supports
  class OrderManager

    def initialize params, shop
      @order_products = OrderProduct.in_date(params[:start_date], params[:end_date])
        .history_orders shop.id
    end

    %i(done rejected).each do |status|
      define_method status do
        @order_products.send(status).group_by{|i| I18n.l(i.created_at, format: :custom_date)}
      end
    end
  end
end
