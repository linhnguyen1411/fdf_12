require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  let!(:user) {FactoryGirl.create :user, name: "Cao Thu Vo Lam"}
  let(:user_a) {FactoryGirl.create :user}

  before do
    admin = FactoryGirl.create :admin
    sign_in admin
  end

  describe "GET #index" do
    subject{assigns(:users)}

    it "search user by name" do
      get :index, params: {search: "Cao Thu Vo Lam"}
      is_expected.to eq([user])
    end

    it "assigns @users without search params" do
      get :index
      is_expected.to eq([user, user_a])
    end
  end

  describe "POST #create" do

    it "create new user with valid params" do
      post :create, params:{ user: {name: "Cao Thu Vo Lam", email: "volamcaothu@gmail.com",
        address: "Da Nang", password: "123123", password_confirmation: "123123"}}
      expect(flash[:success]).not_to be_empty
    end

    it "create new user with invalid params" do
      post :create, params:{ user: {name: "Cao Thu Vo Lam", email: "volamcaothu1@gmail.com",
        address: "Da Nang"}}
      expect(response).to render_template(:new)
    end
  end

  describe "PATCH #update" do
    before do
      request.env["HTTP_REFERER"] = "where_i_came_from"
    end
    it "update status user" do
      patch :update, params: {id: user.id, status: 0}
      response.should redirect_to "where_i_came_from"
    end

    it "update user without status" do
      patch :update, params: {id: user.id, user: {name: "Vo Lam Cao Thu"}}, format: :json
      response.header['Content-Type'].should include 'application/json'
    end

    it "update user fail without status" do
      allow_any_instance_of(User).to receive(:save).and_return false
      patch :update, params: {id: user.id, user: {name: "Vo Lam Cao Thu"}}
      expect(flash[:danger]).not_to be_empty
      expect(response).to render_template(:edit)
    end
  end

  describe "DELETE #destroy" do
    let!(:shop) {FactoryGirl.create :shop, owner_id: user.id}

    before do
      request.env["HTTP_REFERER"] = "where_i_came_from"
    end

    it "delete user who manager shop" do
      delete :destroy, params: {id: user.id}
      expect(flash[:danger]).not_to be_empty
    end

    it "delete user who not have shop" do
      delete :destroy, params: {id: user_a.id}
      expect(flash[:success]).not_to be_empty
    end

    it "delete user fails" do
      allow_any_instance_of(User).to receive(:destroy).and_return false
      delete :destroy, params: {id: user_a.id}
      expect(flash[:danger]).not_to be_empty
    end

    it "delete user not exist" do
      delete :destroy, params: {id: 1000}
      response.should redirect_to "where_i_came_from"
    end
  end
end
