require "rails_helper"

RSpec.describe Admin::HomeController, type: :controller do

  let!(:user_a) {FactoryGirl.create :user}
  let!(:shop_a) {FactoryGirl.create :shop, owner_id: user_a.id}
  let!(:product) {FactoryGirl.create :product, shop_id: shop_a.id}
  before do
    admin = FactoryGirl.create :admin
    sign_in admin
  end

  describe "GET #index" do
    it "assign @users" do
      get :index
      expect(assigns(:users)).to eq([user_a])
    end

    it "assign @shops" do
      get :index
      expect(assigns(:shops)).to eq([shop_a])
    end

    it "assign @products" do
      get :index
      expect(assigns(:products)).to eq([product])
    end
  end
end
