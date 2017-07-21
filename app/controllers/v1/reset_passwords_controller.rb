class V1::ResetPasswordsController < ApplicationController
  before_action :load_user, only: :index
  skip_before_action :verify_authenticity_token, only: :update
 
  def index
    @user.send_reset_password_instructions
    response_success t "api.success"
  end

  def update
    user = User.reset_password_by_token password_params
    return response_success t "api.success" if user.errors.empty?
    response_error t "api.error"
  end

  private

  def load_user
    @user = User.find_by email: params[:user_email]
    response_not_found t "api.not_found" unless @user
  end

  def password_params
    params.permit :password, :password_confirmation, :reset_password_token
  end
end
