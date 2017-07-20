class V1::Dashboard::ShopDomainsController < V1::BaseController
  before_action :load_domain, only: :index

  def index
    shops = Shop.shop_in_domain @domain.id
    if shops.present?
      result = ShopService.new(shops).get_information_all_shops
      response_success t("api.success"), result
    else
      response_not_found t "api.error_list_shop_by_domain_not_found"
    end
  end

  private

  def load_domain
    @domain = Domain.find_by id: params[:domain_id]
    return response_not_found t "api.error_domains_not_found"  unless @domain.present?
  end
end
