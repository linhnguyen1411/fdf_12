class OrderProduct < ApplicationRecord
  strip_attributes only: :notes

  acts_as_paranoid

  belongs_to :user
  belongs_to :order
  belongs_to :product
  belongs_to :coupon

  has_many :events , as: :eventable

  enum status: {pending: 0, accepted: 1, rejected: 2, done: 3}
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :product, prefix: true
  delegate :email, to: :user, prefix: true
  delegate :price, to: :product, prefix: true
  delegate :image, to: :product, prefix: true

  def total_price
    product.price * quantity
  end

  scope :on_today, ->{where "date(order_products.created_at) = date(now())"}
  scope :by_user, ->user {where user: user}
  scope :group_product, -> do
    joins(:product)
      .select("order_products.product_id, sum(order_products.quantity) as total")
      .group("order_products.product_id")
      .order("total DESC")
  end
  scope :history_by_day_with_status, ->(shop_id) do
    joins(:product, :order)
      .select("products.name as name, sum(quantity) as quantity,
        sum(quantity) * products.price as price, order_products.created_at as
        created_at, products.id as product_id, order_products.status as status,
        order_products.id as id")
      .where("orders.status = ? and orders.shop_id = ?",Order.statuses[:done], shop_id)
      .group("order_products.product_id,
        DATE_FORMAT(order_products.created_at, '%Y%m%d')")
  end
  scope :order_products_accepted, -> do
    joins(:product, :order)
      .select("products.name as name, sum(quantity) * products.price as price,
        sum(quantity) as quantity, products.id as product_id, orders.id as shop_id
        , order_products.status as status, order_products.id as id
        , order_products.created_at as date")
      .where("order_products.status = ?",
        OrderProduct.statuses[:accepted])
      .group("order_products.product_id")
  end

  scope :order_done_of_shop, ->(shop_id) do
    includes(:product).eager_load(:order)
      .where("orders.status = ? and
        orders.shop_id = ?", Order.statuses[:done], shop_id)
  end

  scope :history_orders, ->(shop_id) do
    joins(:order)
      .select("order_products.*, orders.end_at as end_at")
      .where("orders.status = ? and orders.shop_id = ?", Order.statuses[:done], shop_id)
      .order("order_products.created_at desc")
  end

  scope :order_by_date, ->{order created_at: :desc}
  scope :order_products_at_date, ->date {where("DATE(created_at) = ?", date)}
  scope :all_order_product_of_list_orders, ->list {where order_id: list}

  scope :in_date, ->start_date, end_date do
    if end_date.present? && start_date.present?
      where("DATE(order_products.created_at) <= ? AND order_products.created_at >= ?",
        end_date.to_date, start_date.to_date)
    elsif end_date.present?
      where("DATE(order_products.created_at) <= ?", end_date.to_date)
    elsif start_date.present?
      where("order_products.created_at >= ?", start_date.to_date)
    else
      where "DATE(order_products.created_at) = date(now())"
    end
  end

  def self.group_by_products_by_created_at
    order_by_date.group_by{|i| i.created_at}
  end

  def send_notification_order
    if self.rejected?
      self.events.create message: :rejected, user_id: self.user.id,
        eventitem_id: self.id
    else
      self.events.create message: :accepted, user_id: self.user.id,
        eventitem_id: self.id
    end
  end
end
