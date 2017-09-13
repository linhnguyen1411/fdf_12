require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:user_diff) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  context 'GET #show' do
    it 'render user show' do
      get :show, id: user.id
      expect(response).to render_template 'show'
    end

    it 'render show user failure' do
      get :show, id: 0
      expect(0).to be_truthy
    end
  end

  context 'PUT #update' do
    it 'true if current_password true' do
      patch :update, params: { id: user.slug, user: { password: '123123',
        password_confirmation: '123123', current_password: user.password } },
        xhr: true
      user.reload
      expect(assigns[:change_password_status]).to eq 0
    end

    it 'false if current_password false' do
      patch :update, params: { id: user.slug, user: { password: '123123',
        password_confirmation: '123123', current_password: '1111111' } },
        xhr: true
      user.reload
      expect(assigns[:change_password_status]).to eq 1
    end

    it 'redirect to user_path if user not current_user' do
      patch :update, params: { id: user_diff.slug, user: { password: '123123',
        password_confirmation: '123123', current_password: user.password } }
      expect(response).to redirect_to user_path user
    end

    it 'redirect to current_user when user update not exist' do
      sign_in user_diff
      patch :update, id: 'linh-nguyen'
      expect(response).to redirect_to user_path user_diff
    end
  end
end
