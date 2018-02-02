require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do

  let(:user) {FactoryGirl.create :user}
  let(:shop) {FactoryGirl.create :shop, owner_id: user.id}
  let!(:product) {FactoryGirl.create :product, shop_id: shop.id}

  before do
    admin = FactoryGirl.create :admin
    sign_in admin
  end

  describe "GET #index" do
    it "assigns @products" do
      get :index
      expect(assigns(:products)).to eq([product])
    end
  end
end
