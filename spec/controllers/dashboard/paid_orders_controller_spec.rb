require "rails_helper"

RSpec.describe Dashboard::PaidOrdersController, type: :controller do
  let(:user) {FactoryGirl.create :user}
  let(:user_a) {FactoryGirl.create :user}
  let(:shop) {FactoryGirl.create :shop, owner_id: user.id}
  let(:product) {FactoryGirl.create :product, shop_id: shop.id, user_id: user.id}
  let(:order) {FactoryGirl.create :order, shop_id: shop.id, user_id: user.id, status: 3}
  let!(:order_product) {FactoryGirl.create :order_product, product_id: product.id, status: 3, order_id: order.id}

  context "GET #index" do
    before do
      sign_in user
    end

    it "returns http success" do
      get :index, xhr: true, params: {shop_id: shop.id}
      expect(response).to render_template("index")
    end

    it "Assigns @order_products_done" do
      get :index, xhr: true, params: {shop_id: shop.id, start_date: "02/02/2018", end_date: "02/02/2018"}
      expect(assigns(:order_products_done)).to eq({"02-02-2018"=>[order_product]})
    end

    it "redirect when load shop fail" do
      get :index, xhr: true, params: {shop_id: 10000}
      expect(response.status).to eq(302)
    end

  end

  context "GET #index with wrong user" do
    before do
      sign_in user_a
    end

    it "redirect if user is not shop manager" do
      get :index, xhr: true, params: {shop_id: shop.id}
      expect(response.status).to eq(302)
    end
  end
  context "GET #show" do
    before do
      sign_in user
    end

    it "response xlsx" do
      get :show, xhr: true, params: {shop_id: shop.id, id: shop.id}, format: :xlsx
      expect(response).to be_success
    end

    it "response csv" do
      get :show, xhr: true, params: {shop_id: shop.id, id: shop.id}, format: :csv
      expect(response).to be_success
    end

    it "response xls" do
      get :show, xhr: true, params: {shop_id: shop.id, id: shop.id}, format: :xls
      expect(response).to be_success
    end
  end
end
