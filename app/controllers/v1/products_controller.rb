class V1::ProductsController < V1::BaseController
  before_action :load_domain, only: :show

  def index
    if params.has_key?(:top_products)
      domain = Domain.find_by id: params[:domain_id]
      if domain.present?
        products = domain.products.top_products
      else
        response_error t "api.error_list_shop_by_domain_not_found"
      end
    else
      products = []
      if params[:domain_id].present?
        Product.includes(:shop).find_each do |t|
          if t.shop.domains.pluck(:id).include?(params[:domain_id].to_i) &&
            t.product_domains.api_find_product_domains(params[:domain_id]) &&
            t.shop.on?
              products << t
          end
        end
      elsif params[:category_id].present?
        Product.includes(:shop).find_each do |t|
          if t.category_id.to_s == params[:category_id] &&
            t.product_domains.api_find_product_domains(params[:domain_id]) &&
            t.shop.on?
              products << t
          end
        end
      elsif params[:shop_id].present?
        Product.includes(:shop).find_each do |t|
          if t.shop_id.to_s == params[:shop_id] &&
            t.product_domains.api_find_product_domains(params[:domain_id]) &&
            t.shop.on?
              products << t
          end
        end
      else
        Product.includes(:shop).find_each do |t|
          if t.product_domains.api_find_product_domains(params[:domain_id]) &&
            t.shop.on?
            products << t
          end
        end
      end
    end
    if products.present?
      result = ActiveModel::Serializer::CollectionSerializer.new(products,
        each_serializer: ProductSerializer)
      response_success t("api.success"), result
    else
      response_not_found t "api.error_products_not_found"
    end
  end

  def show
    shop_ids = Shop.shop_in_domain(@domain.id).on.pluck :id
    products = Product.by_shop_ids(shop_ids).active.search_by_price(params)
      .by_category(params[:category_id]).sort_by_price params[:price_sort]
    if products.present?
      result = ActiveModel::Serializer::CollectionSerializer.new(products,
        each_serializer: ProductSerializer)
      response_success t("api.success"), result
    else
      response_not_found t "api.error_products_not_found"
    end
  end

  private

  def load_domain
    @domain = Domain.find_by id: params[:id]
    return if @domain.present?
    esponse_not_found t "api.not_found"
  end
end
