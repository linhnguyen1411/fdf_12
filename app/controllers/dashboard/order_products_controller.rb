class Dashboard::OrderProductsController < BaseDashboardController
  before_action :load_order_item, only: :update
  before_action :load_shop, only: [:index, :update]

  def index
    orders_ids = Order.by_domain_ids(load_list_manage_domain).orders_of_shop_pending(@shop.id)
      .select{|s| s.order_products.detect{|o| o.pending?} == nil}.pluck(:id)
    @orders = Order.orders_by_list_id orders_ids
    updated_orders = @orders.to_a
    @order_products = OrderProduct.all_order_product_of_list_orders(@orders.ids).accepted
    if (@order_products.update_all status: :done) &&
      (@orders.update_all status: :done)
      OrderProductService.new(updated_orders, @shop).update_order_product
      flash[:success] = t "flash.success.update_order"
      redirect_to dashboard_shop_order_managers_path
      if @orders.present?
        OrderProductService.new(updated_orders, @shop).send_message_to_chatwork
      end
    end
  end

  def update
    if params[:type].to_i == Settings.type_update_all_orders
      list_orders_id = Order.orders_of_shop_pending(params[:shop_id]).ids
      order_products = OrderProduct.all_order_product_of_list_orders list_orders_id
      if order_products.update_all status: params[:status]
        flash[:success] = t "flash.success.update_order"
      else
        flash[:danger] = t "flash.danger.load_items"
      end
      respond_to do |format|
        format.html do
          redirect_to dashboard_shop_orders_path
        end
      end
    else
      order = Order.find_by id: params[:order_product][:order_id]
      if order
        if params[:type].to_i == Settings.type_upload_all_order_products
          if order.order_products.update_all status: params[:order_product][:status]
            order_products = order.order_products
            respond_to do |format|
              format.json do
                render json: {
                  status: params[:order_product][:status],
                  count_pending: order_products.select{|o| o.pending?}.size,
                  count_accepted: order_products.select{|o| o.accepted?}.size,
                  count_rejected: order_products.select{|o| o.rejected?}.size,
                  list_packing: load_list_toal_orders
                }
              end
            end
          else
            render :back
          end
        else
          if @order_product.update_attributes order_product_params
            OrderMailer.shop_confirmation(@order_product).deliver_later
            order_products = order.order_products
            respond_to do |format|
              format.json do
                render json: {
                  status: @order_product.status,
                  count_pending: order_products.select{|o| o.pending?}.size,
                  count_accepted: order_products.select{|o| o.accepted?}.size,
                  count_rejected: order_products.select{|o| o.rejected?}.size,
                  list_packing: load_list_toal_orders
                }
              end
            end
          else
            render :back
          end
        end
      else
        render :back
      end
    end
  end

  private
  def order_product_params
    params.require(:order_product).permit :status
  end

  def load_order_item
    if params[:type].to_i == Settings.type_update_order_product
      @order_product = OrderProduct.find_by id: params[:id]
      unless @order_product
        flash[:danger] = t "flash.danger.load_items"
        redirect_to dashboard_shops_path
      end
    end
  end

  def load_list_toal_orders
    list_orders_id = Order.orders_of_shop_pending(@shop.id).select{|s|
      s.order_products.detect{|o| o.pending?} == nil}.pluck(:id)
    order_products = OrderProduct.all_order_product_of_list_orders(list_orders_id).order_products_accepted
  end

  def load_list_manage_domain
    shop_manager = ShopManager.find_by user_id: current_user.id, shop_id: @shop.id
    if shop_manager.present?
      if shop_manager.owner?
        return @shop.shop_domains.select{|s| s.approved?}.map &:domain_id
      else
        return shop_manager.shop_manager_domains.map &:domain_id
      end
    end
  end
end
