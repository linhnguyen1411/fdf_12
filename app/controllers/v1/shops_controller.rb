class V1::ShopsController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: :update
  before_action :load_domain, only: :index
  before_action :load_shop, only: :update

  def index
    if params.has_key?(:top_shops)
      top_shops = @domain.shops.top_shops
      if top_shops.present?
        response_success t("api.success"), top_shops
      else
        response_not_found t "api.error_list_shop_by_domain_not_found"
      end
    else
      shops = @domain.shops.on
      if shops.present?
        result = ActiveModel::Serializer::CollectionSerializer.new(shops,
          each_serializer: ShopSerializer)
        response_success t("api.success"), result
      else
        response_not_found t "api.error_list_shop_by_domain_not_found"
      end
    end
  end

  def update
    if @shop.shop_owner? current_user.id
      user = User.find_by email: params[:owner_email]
      if user.present?
        if ShopManagerService.new(current_user, user, @shop).change_owner_shop
          response_success t "change_shop"
        else
          response_error t "api.error"
        end
      else
        response_not_found t "api.error_user_not_found"
      end
    else
      response_error t "api.not_owner_shop"
    end
  end

  private
  def load_domain
    @domain = Domain.find_by id: params[:domain_id]
    unless @domain.present?
      response_not_found t "api.error_domains_not_found"
    end
  end

  def load_shop
    @shop = Shop.find_by id: params[:id]
    unless @shop.present?
      response_not_found t "dashboard.shops.not_found"
    end
  end
end
