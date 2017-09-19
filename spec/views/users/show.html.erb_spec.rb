require "rails_helper"

RSpec.describe "users/show.html.erb", type: :view do
  let(:admin) {FactoryGirl.create(:admin)}
  let(:user) {FactoryGirl.create(:user)}

 before(:each) do
    @user = assign(:user, user)
  end

  it "displays user details correctly" do
    render
    expect(subject).to render_template("users/show")
    expect(rendered).to include(user.name)
    expect(rendered).to include(user.email)
    expect(rendered).to include(user.chatwork_id)
  end
end

