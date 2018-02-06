class Admin::UsersController < AdminController
  skip_load_and_authorize_resource only: :update
  before_action :load_user, only: [:update, :destroy]
  authorize_resource

  def index
    if params[:search].present?
      @users = User.search(email_or_name_cont: params[:key_search]).result
    else
      @users = User.all.page(params[:page]).per Settings.common.per_page
    end
    respond_to do |format|
      format.js
      format.html
      format.xls
    end
  end

  def edit
  end

  def create
    @user = User.new newuser_params
    @user.authentication_token = Devise.friendly_token
    if @user.save
      flash[:success] = t "flash.success.admin.created_user"
      redirect_to admin_users_path
    else
      render :new
    end
  end

  def update
    if params[:status].present?
      @user.update_columns status: params[:status]
      redirect_to :back
    else
      if @user.update_attributes user_params
        flash[:success] = t "flash.success.admin.updated_user"
        respond_to do |format|
          format.json do
            render json: {status: @user.status}
          end
          format.html {redirect_to admin_users_path}
        end
      else
        flash[:danger] = t "flash.danger.admin.updated_user"
        render :edit
      end
    end
  end

  def destroy
    if @user.shop_managers.present? || @user.own_domains.present?
      flash[:danger] = t "flash.danger.admin.existing_users_shops"
    else
      if @user.destroy
        flash[:success] = t "flash.success.admin.deleted_user"
      else
        flash[:danger] = t "flash.danger.admin.deleted_user"
      end
    end
    redirect_to admin_users_path
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :chatwork_id, :avatar,
    :description, :status, :address
  end

  def load_user
    begin
      @user = User.friendly.find params[:id]
    rescue
      redirect_to :back
    end
  end

  def newuser_params
    email_settings = {order_request: Settings.serialize_true,
      order_processed: Settings.serialize_true, send_order: Settings.serialize_true}
    notification_settings = {order_request: Settings.serialize_true,
      order_processed: Settings.serialize_true, send_order: Settings.serialize_true}
    params.require(:user).permit(:name, :email, :address, :password,
      :password_confirmation).merge email_settings: email_settings,
      notification_settings: notification_settings, language: I18n.default_locale
  end
end
