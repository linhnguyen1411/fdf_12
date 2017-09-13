class ShopDomainApiService
  def initialize shop_domain, user, status
    @shop_domain = shop_domain
    @user = user
    @status = status
  end

  def change_status
    domain = @shop_domain.domain
    if domain.owner == @user.id || domain.user_domains.manager.find_by(user_id: @user.id).present?
      if @shop_domain.pending?
        ActiveRecord::Base.transaction do
          begin
            if @shop_domain.update_attributes status: @status
              if @shop_domain.approved?
                shop = @shop_domain.shop
                shop.products.find_each do |product|
                  product_domain = ProductDomain.new product_id: product.id,
                  domain_id: domain.id
                  product_domain.save
                end
                return [Settings.api_type_success, I18n.t("api.success")]
              elsif @status == ShopDomain.statuses.key(Settings.shop_domain_status_rejected_key)
                return [Settings.api_type_success, I18n.t("api.success")]
              end
            end
          rescue
            return [Settings.api_type_error, I18n.t("api.error")]
          end
        end
      else
        return [Settings.api_type_error, I18n.t("api.error")]
      end
    else
      return [Settings.api_type_not_found, I18n.t("api.not_owner_domain")]
    end
  end

  def destroy_shop_in_domain
    if @user.domains.find_by(id: @shop_domain.domain_id).present?
      shop = @shop_domain.shop
      if shop.present?
        ActiveRecord::Base.transaction do
          begin
            ShopDomain.destroy_all domain_id: @shop_domain.domain_id, shop_id: shop.id
            list_id_products = shop.products.map &:id
            ProductDomain.list_product_domain_of_shop(list_id_products).destroy_all
            return [Settings.api_type_success, I18n.t("api.success")]
          rescue
            return [Settings.api_type_error, I18n.t("api.error")]
          end
        end
      else
        return [Settings.api_type_error, I18n.t("api.error")]
      end
    else
      return [Settings.api_type_not_found, I18n.t("api.not_owner_domain")]
    end
  end
end
