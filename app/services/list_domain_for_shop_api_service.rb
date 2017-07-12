class ListDomainForShopApiService
  def initialize shop, user
    @shop = shop
    @user = user
  end

  def result
    shop_domain = []
    @user.domains.each do |domain|
      status = domain.shops.include?(@shop) ? @shop.request_status(domain).status : ""
      shop_domain << {domain_id: domain.id, 
        status: status, domain_name: domain.name,
        number_of_users: domain.users.size,
        number_of_shops: domain.shop_domains.approved.size,
        number_of_products: domain.products.size}
    end
    shop_domain
  end
end
