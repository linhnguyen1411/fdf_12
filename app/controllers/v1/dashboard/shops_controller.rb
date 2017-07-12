class V1::Dashboard::ShopsController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: [:create, :update]
  before_action :check_owner_or_manager, only: [:update, :edit, :show]
  before_action :load_shop, only: [:update, :edit, :show]

  def index
    user_id = params[:user_id]
    if user_id.present?
      user = User.find_by id: user_id
      if user.present?
        @list_domains = user.domains
      else
        response_not_found t "api.error_user_not_found"
      end
      @list_shops = Shop.all.select do |shop|
        shop.owner_id.to_s == user_id
      end
      @domain_info = DashboardShopsApiService.new.domain_info user
    else
      response_not_found t "api.error_user_not_found"
    end
    if @list_domains.present? && @list_shops.present?
      response_success t("api.success"), (DashboardShopsApiService.
        new.result_json @list_domains, @list_shops, @domain_info)
    end
  end

  def show
    response_success t("api.success"), list_domain_of_shop
  end

  def create
     @shop = current_user.own_shops.build shop_params
    if @shop.save
      response_success t "api.success"
    else
      response_error t "api.error"
    end
  end

  def update
    if @shop.update_attributes shop_params
      response_success t "api.success"
    else
      response_error t "api.error"
    end
  end

  def edit
    case params[:status]
    when Settings.shop_status_on
      update_on_off_shop @shop, Settings.shop_status_on
    when Settings.shop_status_off
      update_on_off_shop @shop, Settings.shop_status_off
    else
      response_not_found t "api.not_found"
    end
  end

  private
  def shop_params
    params.require(:shop).permit :id, :name, :description,
      :cover_image, :avatar, :time_auto_reject, :time_auto_close, :openforever
  end

  def check_owner_or_manager
    shop_manager = ShopManager.find_by user_id: current_user.id, shop_id: params[:id]
    unless shop_manager.present? && (shop_manager.owner? || shop_manager.manager?)
      response_error t "not_have_permission"
    end
  end

  def load_shop
    @shop = Shop.find_by id: params[:id]
    unless @shop.present?
      response_not_found t "api.not_found"
    end
  end

  def update_on_off_shop shop, status
    if shop.update_attribute :status_on_off, status
      response_success t "api.success"
    else
      response_error t "api.error"
    end
  end

  def list_domain_of_shop
    ListDomainForShopApiService.new(@shop, current_user).result
  end
end
