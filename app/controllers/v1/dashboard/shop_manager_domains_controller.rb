class V1::Dashboard::ShopManagerDomainsController < V1::BaseController
  skip_before_action :verify_authenticity_token, only: [:destroy, :create]
  before_action :load_shop
  before_action :load_domain
  before_action :load_shop_manager, only: [:destroy, :create]
  before_action :check_manager_domain_exist, only: :create

  def index
   result = ShopManagerDomainApiService.new(@domain.users, @domain, @shop).list_user
   response_success t("api.success"), result
  end

  def create
    shop_manager_domain = @shop_manager.shop_manager_domains
      .new domain_id: params[:domain_id]
    return response_success t "api.success" if shop_manager_domain.save
    response_error t "api.error"
  end

  def destroy
    shop_manager_domain = @shop_manager
      .shop_manager_domains.find_by domain_id: params[:domain_id]
    if shop_manager_domain.present? && shop_manager_domain.destroy
      response_success t "api.success"
    else
      response_not_found t "api.not_found"
    end
  end

  private

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]  
    return response_not_found t "api.not_found"  unless @shop.present?
    shop_manager = ShopManager.find_by user_id: current_user.id, shop_id: @shop.id
    unless shop_manager.present? && (shop_manager.owner? || shop_manager.manager?)
      response_error t "not_have_permission"
    end
  end

  def load_domain
    @domain = Domain.find_by id: params[:domain_id]
    return response_not_found t "api.error_domains_not_found"  unless @domain.present?
    unless @shop.in_domain? @domain
      response_error t "not_have_permission"
    end
  end

  def load_shop_manager
    @shop_manager = ShopManager.create_with(role: :manager)
      .find_or_create_by user_id: params[:user_id], shop_id: params[:shop_id]
    response_not_found t "api.not_found" unless @shop_manager
  end

  def check_manager_domain_exist
    shop_manager_domain = @shop_manager.shop_manager_domains
      .find_by domain_id: params[:domain_id]
    response_error t "api.error" if shop_manager_domain.present?
  end
end
