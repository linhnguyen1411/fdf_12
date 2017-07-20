class V1::ShopDomainsController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: [:update, :destroy, :create]
  before_action :load_shop_domain, only: [:update, :destroy]
  before_action :check_owner_or_manager, only: :create
  before_action :load_shop, only: :create
  before_action :load_doamin, only: :create
  before_action :check_shop_domain, only: :create

  def index
    domain_id = params[:domain_id]
    if domain_id.present?
      list_shops_by_domain = ShopDomain.all.select do |t|
        t.domain_id.to_s == domain_id
      end
      if list_shops_by_domain.present?
        result = ActiveModelSerializers::SerializableResource.new list_shops_by_domain
        response_success t("api.success"), result
      else
        response_not_found t("api.error_list_shop_by_domain_not_found")
      end
    else
      response_not_found t("api.error_domains_not_found")
    end
  end

  def update
    if ShopDomain.statuses[params[:status]].present?
      result = ShopDomainApiService.new(@shop_domain, current_user,
        params[:status]).change_status
      responses result
    else
      response_not_found t "api.status_not_exist"
    end
  end

  def destroy
    if params[:leave_domain].present?
      shop = Shop.find_by id: params[:shop_id]
      if shop.is_owner? current_user
        result = ShopDomainApiService.new(@shop_domain, current_user, "").destroy_shop_in_domain
        responses result
      else
        response_error t "api.not_owner_shop"
      end
    else
      result = ShopDomainApiService.new(@shop_domain, current_user, "").destroy_shop_in_domain
      responses result
    end
  end

  def show
    if current_user.domains.find_by(id: params[:domain_id]).present?
      list_request = ShopDomain.request_of_domain params[:domain_id]
      result = ActiveModel::Serializer::CollectionSerializer
        .new list_request, each_serializer: ShopDomainSerializer
      response_success t("api.success"), result
    else
      response_error t "api.not_owner_domain"
    end
  end

  def create
    if check_owner_or_manager_of_domain
      shop_domain = ShopDomain.new shop_id: @shop.id, domain_id: @domain.id,
        status: :approved
    else
      shop_domain = ShopDomain.new shop_id: @shop.id, domain_id: @domain.id,
        status: :pending
    end
    if shop_domain.save
      check_save_shop_domain shop_domain
      response_success t "api.success"
    else
      response_error t "api.error"
    end
  end

  private
  def load_shop_domain
    @shop_domain = ShopDomain.find_by domain_id: params[:domain_id],
      shop_id: params[:shop_id]
    unless @shop_domain.present?
      response_not_found t "api.not_found"
    end
  end

  def responses result
    case result.first
    when Settings.api_type_success
      response_success result.last
    when Settings.api_type_error
      response_error result.last
    when Settings.api_type_not_found
      response_not_found result.last
    end
  end

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop.present?
      response_not_found t "api.not_found"
    end
  end

  def load_doamin
    @domain = Domain.find_by id: params[:domain_id]
    unless @domain.present?
      response_not_found t "api.not_found"
    end
  end

  def check_save_shop_domain shop_domain
    shop_domain.create_event_request_shop @domain.owner, shop_domain
    sent_notification_domain_manager @domain, shop_domain
    if shop_domain.approved?
      AddShopProductToDomainService.new(@shop, @domain).add
    end
  end

  def check_owner_or_manager_of_domain
    user_doamin = UserDomain.find_by user_id: current_user.id, domain_id: @domain.id
    return user_doamin.present? && (user_doamin.owner? || user_doamin.manager?)
  end

  def check_shop_domain
    shop_domain = ShopDomain.find_by domain_id: @domain, shop_id: @shop.id
    if shop_domain.present?
      if shop_domain.approved?
        response_success t "api.success"
      elsif shop_domain.rejected?
        if check_owner_or_manager_of_domain
          if shop_domain.update_attributes status: :approved
            check_save_shop_domain shop_domain
            response_success "api.success"
          else
            response_error "update fail"
          end
        else
          if shop_domain.update_attributes status: :pending
            check_save_shop_domain shop_domain
            response_success t "api.success"
          else
            response_error "api.error"
          end
        end
      elsif shop_domain.pending?
        response_success t "api.success"
      end
    end
  end

  def sent_notification_domain_manager domain, shop_domain
    domain.user_domains.each do |user_domain|
      if user_domain.manager? || user_domain.owner?
        shop_domain.create_event_request_shop user_domain.user_id, shop_domain
      end
    end
  end
end
