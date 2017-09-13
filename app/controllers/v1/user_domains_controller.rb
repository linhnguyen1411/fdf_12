class V1::UserDomainsController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: [:create, :destroy, :update]
  before_action :load_user
  before_action :load_domain

  def create
    if @domain.owner?(current_user.id) || @domain.user_domains.manager.find_by(user_id: current_user.id).present?
      user_domain = UserDomain.new user_domain_params
      if user_domain.save
        user_domain.create_event_add_user_domain @user.id
        response_success t "api.success"
      else
        response_error t "api.error"
      end
    else
      response_error t "api.not_owner_domain"
    end
  end

  def update
    user_domain = UserDomain.find_by domain_id: params[:domain_id],
      user_id: params[:user_id]
    if user_domain.present?
      if @domain.owner? current_user.id
        if @user == current_user
          response_error t "api.error_owner_delete_yourself"
        else
          if params[:role] == Settings.user_domain_role.member ||
            params[:role] == Settings.user_domain_role.manager
            if user_domain.update_attributes role: params[:role]
              response_success t "api.success"
            else
              response_error t "api.error"
            end
          else
            response_error t "api.error"
          end
        end
      else
       response_error t "api.not_owner_domain"
      end
    else
      response_error t "api.not_found"
    end
  end

  def destroy
    user_domain = UserDomain.find_by domain_id: params[:domain_id],
      user_id: params[:user_id]
    if user_domain.present?
      if @domain.owner? current_user.id
        if @user == current_user
          response_error t "api.error_owner_delete_yourself"
        else
          destroy_user_domain user_domain
        end
      else
        if user_domain.user_id == current_user.id
          destroy_user_domain user_domain
        else
          response_error t "api.error_delete_member"
        end
      end
    else
      response_error t "api.not_found"
    end
  end

  private

  def user_domain_params
    params.require(:user_domain).permit(:domain_id, :user_id).merge role: :member
  end

  def load_user
    if params[:user_domain].present?
      @user = User.find_by id: params[:user_domain][:user_id]
    else
      @user = User.find_by id: params[:user_id]
    end
    unless @user
      response_error t "api.error_user_not_found"
    end
  end

  def load_domain
    if params[:user_domain].present?
      @domain = Domain.find_by id: params[:user_domain][:domain_id]
    else
      @domain = Domain.find_by id: params[:domain_id]
    end
    unless @domain
      response_error t "api.error_domains_not_found"
    end
  end

  def destroy_user_domain user_domain
    if user_domain.destroy
      response_success t "api.success"
    else
      response_error t "api.error"
    end
  end
end
