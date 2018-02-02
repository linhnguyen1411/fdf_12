require "rails_helper"

RSpec.describe Admin::DomainsController, type: :controller do
  let(:domain_a) {FactoryGirl.create :domain}
  before do
    admin = FactoryGirl.create :admin
    sign_in admin
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assign @domains" do
      get :index
      expect(assigns(:domains)).to eq([domain_a])
    end
  end

  describe "POST #show" do
    it "response json" do
      post :show, params: {id: domain_a.id}, format: :json
      response.header['Content-Type'].should include 'application/json'
    end
  end
end
