class V1::ShopManagersController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: :create
  before_action :load_shop, only: :create
  before_action :load_user_domain, only: :create

  def index
    shop = Shop.find_by id: params[:shop_id]
    if shop.present?
      user_managers = shop.shop_managers
      response_list user_managers, ShopManagerSerializer, ""
    else
      response_not_found "shop_not_found"
    end
  end

  def create
    if @shop.shop_owner? current_user.id
      if @user.user_id == current_user.id
        response_error t "api.error_add_yourself"
      else
        current_manager = ShopManager.find_by user_id: params[:user_id],
          shop_id: params[:shop_id], role: :manager
        if current_manager.present?
          response_error t "api.error_already_manager"
        else
          shop_manager = ShopManager.new user_id: params[:user_id],
            shop_id: params[:shop_id], role: :manager
          if shop_manager.save
            response_success t "api.success"
          else
            response_error t "api.error"
          end
        end
      end
    else
      response_error t "api.not_owner_shop"
    end
  end

  private
  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop.present?
      response_not_found t "api.not_found"
    end
  end

  def load_user_domain
    @user = UserDomain.find_by user_id: params[:user_id], domain_id: params[:domain_id]
    unless @user.present?
      response_not_found t "api.error_user_not_found"
    end
  end
end
