class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    if User.friendly.exists? params[:id]
      @user = User.friendly.find params[:id]
    else
      flash[:danger] = t "flash.danger_message"
      redirect_to root_path
    end
  end

  def update
    user = User.friendly.find_by slug: params[:id]
    if user.present?
      if user == current_user
        if user.valid_password? params[:user][:current_password]
          user.update_attributes user_params
          bypass_sign_in user
          @change_password_status = Settings.status_save.success
        else
          @change_password_status = Settings.status_save.error
        end
      else
        flash[:danger] = t "api.error"
        redirect_to user_path current_user
      end
    else
      flash[:danger] = t "api.error_user_not_found"
      redirect_to user_path current_user
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end
end
