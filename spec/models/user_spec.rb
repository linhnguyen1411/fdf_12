require "rails_helper"

RSpec.describe User, type: :model do

  let(:user) {FactoryGirl.create(:user)}
  subject {user}

  auth_hash = OmniAuth::AuthHash.new({
    provider: "facebook",
    uid: "1234",
    info: {
      email: "user@example.com",
      name: "Justin Bieber"
    }
  })

  describe ".from_omniauth" do
    it "retrieves an existing user" do
      user = User.new(
        provider: "facebook",
        uid: 1234,
        email: "user@example.com",
        password: "password",
        password_confirmation: "password"
        )
      user.save
      omniauth_user = User.from_omniauth(auth_hash)
      expect(user).to eq(omniauth_user)
    end

    it "creates a new user if one doesn't already exist" do
      expect{User.from_omniauth(auth_hash)}.to change(User, :count).by 1
    end
  end

  context "relationship" do
    it {is_expected.to have_many :shop_managers}
    it {is_expected.to have_many :shops}
    it {is_expected.to have_many :own_shops}
    it {is_expected.to have_many :comments}
    it {is_expected.to have_many :products}
    it {is_expected.to have_many :orders}
    it {is_expected.to have_many :order_products}
    it {is_expected.to have_many :coupons}
    it {is_expected.to have_many :events}
  end

  context "validates" do
    it {expect validate_presence_of :name}
  end

  describe "scope" do
    it "scope create_at DESC by_date_newest" do
      user_x = mock_model User, created_at: DateTime.new(2016,01,01)
      user_y = mock_model User, created_at: DateTime.new(2016,02,01)
      user_z = mock_model User, created_at: DateTime.new(2016,03,01)
      expect_result = [user_z, user_y, user_x]
      User.stub(:recent).and_return expect_result
      expect(User.recent).to eq(expect_result)
    end
  end
  let!(:user1){FactoryGirl.create :user, created_at: Time.now}
  let!(:user2){FactoryGirl.create :user, created_at: Time.now + 1.hour}
  let!(:user3){FactoryGirl.create :user, created_at: Time.now + 2.hour, status: 0}
  describe "scope" do
    it ".by_date_newest" do
      expect_result = [user3, user2, user1]
      expect(User.by_date_newest).to eq(expect_result)
    end

    it ".of_ids" do
      expect(User.of_ids(user1.id)).to eq([user1])
    end

    it ".list_all_users" do
      expect(User.list_all_users([user1.id,user2.id])).to eq([user1,user2])
    end

    it ".user_of_list_id_include_role" do
      a = user1.user_domains.new(role: 2)
      expect(User.user_of_list_id_include_role([user1.id,user2.id], 1)).to eq([])
    end
  end
end
