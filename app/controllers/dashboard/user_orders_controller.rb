class Dashboard::UserOrdersController < BaseDashboardController
  before_action :load_shop

  def index
    @order_products_done = OrderProduct.in_date(params[:start_date], params[:end_date])
      .done.order_by_date.order_done_of_shop(@shop.id).group_by{|i| l(i.created_at, format: :custom_date)}
    @order_products_reject = OrderProduct.in_date(params[:start_date], params[:end_date])
      .rejected.order_by_date.order_done_of_shop(@shop.id).group_by{|i| l(i.created_at, format: :custom_date)}
    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
  end

  def show
    if params[:type] == Settings.filter_status_order.done
      @order_products = OrderProduct.in_date(params[:start_date], params[:end_date])
        .done.order_by_date.order_done_of_shop(@shop.id).group_by{|i| l(i.created_at, format: :custom_date)}
    else
      @order_products = OrderProduct.in_date(params[:start_date], params[:end_date])
        .rejected.order_by_date.order_done_of_shop(@shop.id).group_by{|i| l(i.created_at, format: :custom_date)}
    end
    file_name = I18n.l(DateTime.now, format: :long).to_s
    respond_to do |format|
      format.html
      format.xls do
        headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.xls\""
        headers["Content-Type"] ||= Settings.xls
      end
      format.csv do
        headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.csv\""
        headers["Content-Type"] ||= Settings.csv
      end
      format.xlsx do
        headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.xlsx\""
        headers["Content-Type"] ||= Settings.xlsx
      end
    end
  end

  private
  def load_shop
    params[:shop_id] = params[:id] if params[:id]
    if Shop.exists? params[:shop_id]
      @shop = Shop.find_by id: params[:shop_id]
      shop_manager = @shop.shop_managers.find_by(user_id: current_user.id)
      unless shop_manager.present? && (shop_manager.owner? || shop_manager.manager?)
        flash[:danger] = t "not_have_permission"
        redirect_to dashboard_shops_path
      end
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shops_path
    end
  end
end
