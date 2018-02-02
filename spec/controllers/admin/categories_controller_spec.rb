require "rails_helper"

RSpec.describe Admin::CategoriesController , type: :controller do
  let(:category) do
    mock_model Category, name: "category"
  end
  let!(:category_a) {FactoryGirl.create :category}

  before do
    admin = FactoryGirl.create :admin
    sign_in admin
  end

  describe "GET #index" do
    it "should index all category" do
      get :index
      expect(response).to render_template "index"
    end
  end

  describe "GET #new" do
    it "should created category" do
      get :new
      expect(response).to render_template "new"
    end
  end

  describe "POST #create" do
    it "created category" do
      post :create, category: {name: "category"}
      response.should redirect_to admin_categories_path
    end

    it "don't created category" do
      post :create, category: {name: nil}
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "should render edit" do
      get :edit, id: category_a.id
      expect(response).to render_template "edit"
    end
  end

  describe "PATCH #update" do
    it "should update category" do
      patch :update, params: {id: category_a.id, category: {name: "category2"}}
      expect(response).to redirect_to admin_categories_path
    end

    it "don't update category" do
      patch :update, id: category_a.id, category: {name: ""}
      expect(response).to render_template "edit"
    end
  end

  describe "DELETE #destroy" do

    it "deleted category" do
      delete :destroy, {id: category_a.id}
      expect(flash[:success]).not_to be_empty
    end

    context "delete fail" do
      let(:user) {FactoryGirl.create :user}
      let(:shop) {FactoryGirl.create :shop, owner_id: user.id}
      let!(:product) {FactoryGirl.create :product, category_id: category_a.id, shop_id: shop.id}

      it "delete with exist product have category_a" do
        delete :destroy, {id: category_a.id}
        expect(flash[:warning]).not_to be_empty
      end
    end

    it "delete categroy fails with right params" do
      allow_any_instance_of(Category).to receive(:destroy).and_return false
      delete :destroy, {id: category_a.id}
      expect(flash[:danger]).not_to be_empty
    end
  end
end
