class UserDomainsController < ApplicationController
  before_action :load_data
  before_action :load_domain_by_param, except: :update
  before_action :load_user_domain, only: [:update, :destroy]
  before_action :authenticate_user!
  skip_before_action :check_current_domain

  def index
    @users = @choosen_domain.users
  end

  def new
    unless @choosen_domain
      flash[:danger] = t "can_not_load_domain"
      redirect_to :back
    end
    @users = User.by_active.page(params[:page]).per Settings.common.per_page
  end

  def create
    if @user
      user_domain = UserDomain.new user_id: @user.id,
        domain_id: @choosen_domain.id, role: :member
      save_user_domain user_domain
    else
      flash[:danger] = t "can_not_find_user"
      redirect_to root_path
    end
  end

  def update
    if @user_domain.update_attributes(role: params[:role])
      message = @user_domain.manager? ?
        t("manage_domain.add_manager_successfully")
        : t("manage_domain.remove_manager_successfully")
    else
      message = t("manage_domain.add_manager_faild")
    end
    @user_domain.create_event_add_manager_domain @user_domain.user_id
    render_js message
  end

  def destroy
    if @user_domain.destroy
      domain = Domain.find_by id: @user_domain.domain_id
      delete_cart_domain domain
      if current_user.domains.include? @choosen_domain
        if request.xhr?
          @users = User.not_in_domain @choosen_domain
          respond_to do |format|
            format.js
          end
        end
      else
        flash[:success] = t "leave_domain_success" if params[:leave_domain].present?
        flash[:success] = t "delete_domain" if params[:delete_user_domain].present?
        redirect_to domains_path
      end
    end
  end

  private
  def load_data
    if params[:user_id]
      @user = User.find_by id: params[:user_id]
    elsif params[:email]
      @user = User.find_by email: params[:email]
    end
    return unless @user
    @products = @user.products
    @shops = @user.shops
  end

  def save_user_domain user_domain
    if user_domain.save
      if @domain.owner? current_user.id
        user_domain.create_event_add_user_domain @user.id
      elsif current_user.is_user? @user.id
        user_domain.create_event_add_user_domain @domain.owner
        sent_notification_domain_manager @domain
      end
      message = params[:join_domain].present? ?
        t("join_domain_success") : t("add_domain")
    else
      message = t("can_not_add_account")
    end
    if request.xhr?
      @users = User.not_in_domain @choosen_domain
      render_js message
    else
      flash[:success] = message
      redirect_to :back
    end
  end

  def load_user_domain
    @user_domain = UserDomain.find_by id: params[:id]
    unless @user_domain.present?
      redirect_to :back
      flash[:danger] = t "can_not_load_user"
    end
  end

  def sent_notification_domain_manager domain
    domain.user_domains.each do |usr_domain|
      if usr_domain.manager?
        usr_domain.create_event_add_user_domain usr_domain.user_id
      end
    end
  end

  def render_js message
    @message = message
    respond_to do |format|
      format.js
    end
  end

  def delete_cart_domain domain
    carts_domain = @cart_domain.carts.select{|cart| cart.domain_id == domain.id}
    if carts_domain.present?
      @cart_domain.detele_cart carts_domain
      session[:cart_domain] = @cart_domain.update_cart
    end
  end
end
