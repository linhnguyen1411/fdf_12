module OrdersHelper
  def shop_domain_select shop
    shop_manager = ShopManager.find_by user_id: current_user.id, shop_id: shop.id
    if shop_manager.present?
      if shop_manager.owner?
        domain_ids = @shop.shop_domains.select{|s| s.approved?}.map &:domain_id
      else
        domain_ids = shop_manager.shop_manager_domains.map &:domain_id
      end
    end
    domains = Domain.list_domain_by_ids domain_ids
    domains.map{|domain| [domain.name, domain.id]}
  end

  def user_name_for_id id
    user = User.find_by id: id
    user.name if user
  end

  def user_office_for_id order_products
    id = order_products.first
    user = User.find_by id: id
    if user
      user_domain = Domain.find_by id: user.domain_default
      if user_domain.present?
        user_domain.name
      else
        I18n.t("user_order_no_office")
      end
    end
  end
  def order_manage_filter
    {
      I18n.t("order_manage_filter.product") => "product",
      I18n.t("order_manage_filter.user") => "user",
      I18n.t("order_manage_filter.group") => "group",
      I18n.t("order_manage_filter.time") => "time",
      I18n.t("order_manage_filter.payment") => "paid",
    }
  end

  def sum_price orders
    orders.sum{|order| total_price(order.product_price, order.quantity)}
  end

  def group_by_user orders
    orders.group_by{|u| u.user_id}
  end

  def group_by_user_group orders
    orders.group_by{|u| u.user.address.upcase if u.user.address.present?}
  end

  def group_by_time_approve orders
    orders.group_by{|o| o.end_at}
  end

  def group_by_paid order_products
    order_products.group_by{|o| o.order.is_paid}
  end

  def accepted_products order_products
    order_products.sum{|o| o.accepted? || o.done? ? o.quantity : 0 }
  end

  def rejected_products order_products
    order_products.sum{|o| o.rejected? ? o.quantity : 0 }
  end

  def total_pay order_products
    order_products.sum{|o| o.accepted? || o.done? || o.pending? ? o.quantity * o.product_price : 0}
  end

  def group_by_order order_products
    order_products.group_by{|u| u.order}
  end

  def order_paid_status_label order
    order.is_paid ?
      content_tag(:span, t("paid"), class: "paid-order") :
      content_tag(:span, t("unpaid"), class: "unpaid-order")
  end

  def order_paid_status_text order
    order.is_paid ? t("paid") : t("unpaid")
  end

  def paid_in_order_history_btn order
    if order.is_paid?
      content_tag(:i, "", class: "glyphicon glyphicon-check btn_done") +
      (link_to t("unpaid"), "#",
        class: "paid-history-btn",
        data: {order_id: order.id, shop_id: order.shop.id, checked: false})
    else
      content_tag(:i, "", class: "glyphicon glyphicon-check btn_done") +
      (link_to t("pay_order"), "#",
        class: "paid-history-btn",
        data: {order_id: order.id, shop_id: order.shop.id, checked: true})
    end
  end
end
