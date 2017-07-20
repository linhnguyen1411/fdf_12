class V1::Dashboard::ShopManagerDomainsController < V1::BaseController
  before_action :load_shop
  before_action :load_domain

  def index
   result = ShopManagerDomainApiService.new(@domain.users, @domain, @shop).list_user
   response_success t("api.success"), result
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
end
