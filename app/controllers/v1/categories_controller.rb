class V1::CategoriesController < V1::BaseController
  def index
    if params[:domain_id].present?
      domain = Domain.find_by id: params[:domain_id]
      if domain.present?
        categories = Category.all.select do |category|
          number_product_in_category_by_domain(category, domain) > Settings.min_product_in_category
        end
        if categories.present?
          response_success t("api.success"), categories
        else
          response_not_found t "api.error_categories_not_found"
        end
      else
        response_not_found t "api.error_domains_not_found"
      end
    else
      categories = Category.all
      response_success t("api.success"), categories
    end
  end
end
