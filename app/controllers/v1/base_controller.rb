class V1::BaseController < ApplicationController
  acts_as_token_authentication_handler_for User

  def check_owner_or_manager
    shop_manager = ShopManager.find_by user_id: current_user.id, shop_id: params[:shop_id]
    unless shop_manager.present? && (shop_manager.owner? || shop_manager.manager?)
      response_error t "not_have_permission"
    end
  end

  def response_list list, serializer, not_found_message
    if list.present? 
      results = ActiveModel::Serializer::CollectionSerializer
        .new list, each_serializer: serializer
      response_success t("api.success"), results
    else
      response_not_found not_found_message
    end
  end
end
