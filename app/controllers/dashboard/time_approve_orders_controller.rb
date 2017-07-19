class Dashboard::TimeApproveOrdersController < BaseDashboardController
  before_action :load_shop
  before_action :create_order_manager_support

  def index  
    respond_to do |format|
      format.js
    end
  end

  def show
    file_name = I18n.l(DateTime.now, format: :long).to_s
    respond_to do |format|
      format.html
      %i(xls csv xlsx).each do |type|
        format.send(type) do
          headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.#{type}\""
          headers["Content-Type"] ||= Settings.format_type.send(type)
        end
      end
    end
  end
 
  private

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    
    if @shop.present?
      shop_manager = @shop.shop_managers.find_by user_id: current_user.id
      return if shop_manager.present? && (shop_manager.owner? || shop_manager.manager?)
      flash[:danger] = t "not_have_permission"
      redirect_to dashboard_shops_path
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shops_path
    end
  end

  def create_order_manager_support
    @history_orders = Supports::OrderManager.new params, @shop
  end
end
