class ShopManagerDomainApiService

  def initialize users, domain, shop
    @users = users
    @domain = domain
    @shop = shop
  end

  def list_user
    result = []
    @users.each do |user|
      role = ""
      user_hash = user.slice :id, :name, :description, :status, :avatar, :email
      shop_manager = ShopManager.find_by user_id: user.id, shop_id: @shop.id
      if shop_manager.present?
        shop_manager_domain = shop_manager
          .shop_manager_domains.by_domain(@domain.id).first
        role = shop_manager_domain.present? ? :manager : :owner
      end
      user_hash["shop_manager_domain"] = role
      result << user_hash
    end
    result
  end
end
