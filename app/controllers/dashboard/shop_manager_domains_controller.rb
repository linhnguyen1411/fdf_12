class Dashboard::ShopManagerDomainsController < ApplicationController
  before_action :load_domain_by_param
  before_action :load_shop
  before_action :load_shop_manager, only: [:create, :destroy]
  before_action :authenticate_user!
  skip_before_action :check_current_domain

  def index
    q = params[:user_search]
    @users = @choosen_domain.users.active.search(name_or_email_cont: q).result
    respond_to do |format|
      format.js
    end
  end

  def create
    @shop_manager_domain = @shop_manager.shop_manager_domains
      .new domain_id: params[:domain_id]
    if @shop_manager_domain.save
      respond_to do |format|
        format.js
      end
    else
      flash[:danger] = t "flash.danger_message"
      redirect_to :back
    end
  end

  def destroy
    @choosen_user = @shop_manager.user
    shop_manager_domain = @shop_manager.shop_manager_domains.by_domain(params[:domain_id]).first
    if shop_manager_domain.present? && shop_manager_domain.destroy
      @shop_manager.destroy unless @shop_manager.shop_manager_domains.present?
      respond_to do |format|
        format.js
      end
    else
      flash[:danger] = t "flash.danger_message"
      redirect_to :back
    end
  end

  private
  def load_shop
    if Shop.exists? params[:shop_id]
      @shop = Shop.find params[:shop_id]
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to root_path
    end
  end

  def load_shop_manager
    @shop_manager = ShopManager.create_with(role: :manager)
      .find_or_create_by(user_id: params[:user_id], shop_id: params[:shop_id])
  end
end
