require "rails_helper"

RSpec.describe Admin::OrdersController, type: :controller do

  let(:user) {FactoryGirl.create :user}
  let(:shop) {FactoryGirl.create :shop, owner_id: user.id}
  let!(:order) {FactoryGirl.create :order, shop_id: shop.id, user_id: user.id}

  before do
    admin = FactoryGirl.create :admin
    sign_in admin
  end

  describe "GET #index" do
    it "assigns @orders" do
      get :index
      expect(assigns(:orders)).to eq([order])
    end
  end

end
