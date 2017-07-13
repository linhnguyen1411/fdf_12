class V1::Dashboard::ProductsController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: [:create, :update, :destroy]
  before_action :load_shop, only: :create
  before_action :check_owner_shop, only: :destroy
  before_action :load_product, only: :destroy

  def create
    shop_manager = ShopManager.find_by user_id: current_user.id, shop_id: @shop.id
    if shop_manager.present? && (shop_manager.owner? || shop_manager.manager?)
      @product = @shop.products.new product_params
      if @product.save
        response_success t "api.success"
      else
        response_error t "flash.danger.dashboard.create_product"
      end
    else
      response_error t "not_have_permission"
    end
  end

  def update
    product = Product.find_by id: params[:id]
    if product
      if product.update_attributes product_params
        response_success t "api.success"
      else
        response_error t "flash.danger.dashboard.edit_product"
      end
    else
      response_not_found t "flash.danger.dashboard.product.not_found"
    end
  end

  def destroy
    if @product.order_products.any?
      response_error t "flash.danger.dashboard.order_product"
    elsif @product.destroy
      response_success t "flash.success.dashboard.delete_product"
    else
      response_error t "flash.danger.dashboard.delete_product"
    end
  end

  private
  def load_shop
    @shop = Shop.find_by id: params[:product][:shop_id]
    unless @shop.present?
      response_not_found t "api.not_found"
    end
  end

  def product_params
    params.require(:product).permit(:name, :description, :price,
      :category_id, :image, :status, :tag_list, :start_hour, :end_hour).merge! user_id: current_user.id
  end

  def load_product
    @product = Product.find_by id: params[:id], shop_id: params[:shop_id]
    unless @product.present?
      response_not_found t "api.error_products_not_found"
    end
  end

  def check_owner_shop
    shop = Shop.find_by id: params[:shop_id]
    if shop.present?
      unless shop.shop_owner? current_user.id
        response_error t "api.not_owner_shop"
      end
    else
      response_not_found t "api.not_found"
    end
  end
end
