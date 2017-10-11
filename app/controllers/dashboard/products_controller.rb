class Dashboard::ProductsController < BaseDashboardController
  before_action :load_shop
  before_action :load_categories, only: [:edit, :new, :update]
  before_action :load_product, except: [:new, :index, :create]
  before_action :load_products, only: :index

  def new
    @product = @shop.products.new
  end

  def index
    @products.page(params[:page]).per Settings.common.products_per_page
  end

  def show
    @order_item = OrderProduct.find_by id: params[:order_product_id]
    if @order_item
      date = Date.parse @order_item.created_at.to_s
      case
      when @order_item.done?
        @order_products = @product.order_products.order_products_at_date(date)
          .includes(:user).done
      when @order_item.rejected?
        @order_products = @product.order_products.order_products_at_date(date)
          .includes(:user).rejected
      else
        @order_products = @product.order_products.order_products_at_date(date)
          .includes(:user).accepted
      end
      file_name = I18n.l(DateTime.now, format: :short_date).to_s
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
      end
    else
      flash[:danger] = t "flash.danger.dashboard.product.not_found"
      redirect_to root_path
    end
  end

  def edit
  end

  def create
    @product = @shop.products.new product_params
    @success = @product.save ? true : false
    load_products_by_size if @success
    respond_to do |format|
      format.js
    end
  end

  def update
    @success = @product.update_attributes(product_params) ? true : false
    @products = @shop.products.by_date_newest.limit params[:hidden_products_size] if @success
    respond_to do |format|
      format.json do
        render json: {status: @product.status}
      end
      format.js
    end
  end

  def destroy
    if @product.order_products.any?
      @destroy_product_status = Settings.destroy_product_status.has_order
    elsif @product.destroy
      load_products
      @destroy_product_status = Settings.destroy_product_status.success
    else
      @destroy_product_status = Settings.destroy_product_status.error
    end
  end

  private
  def load_shop
    @shop = Shop.find_by slug: params[:shop_id]
    unless @shop.present?
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shop_path
    end
  end

  def product_params
    params.require(:product).permit :id, :name, :description, :price, :crop_product_x,
      :crop_product_y, :crop_product_w, :crop_product_h,
      :category_id, :user_id, :image, :status, :tag_list, :start_hour, :end_hour
  end

  def load_categories
    @categories = Category.all
  end

  def load_products
    @products = @shop.products
  end

  def load_product
    @product = @shop.products.find_by slug: params[:id]
    if @products
      flash[:danger] = t "flash.danger.dashboard.product.not_found"
      redirect_to root_path
    end
  end

  def load_products_by_size
    product_size = params[:hidden_products_size].to_i
    limit_product =
      if @shop.products.size == increase_one(product_size)
        increase_one product_size
      else
        product_size
      end
    @products = @shop.products.by_date_newest.limit limit_product
  end
end
